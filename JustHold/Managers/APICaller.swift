import UIKit
import Alamofire

// Coinmarketcap dashboard with statistics - https://pro.coinmarketcap.com/account
// API documentation - https://coinmarketcap.com/api/documentation/v1/


// Позже. Сделать проверку на время последнего обновления монет, похожее на isTimeToUpdateMap, чтобы оптимизировать кол-во запросов

// Попробовать такой вариант. Будет работать или нет смысла в таком? Как тогда передавать queryParams? (в контроллере сохранять queryParams в PersistenceManager, а во время запроса брать оттуда queryParams)
// В Persistence manager создать public var coinsListing (или private set попробовать) для хранения монет с запроса
// В коде я обращаюсь сразу к coinsListing, чтобы получить монеты
// У coinsListing в get прописана проверка на время (запрос не чаще раза в минуту), если запрос был больше минуты назад, то там же вызывать метод из APICaller, который загрузит новые данные для монет

// Для FetchQuotes сначала делать проверку на время, а потом проверку на то, остался ли список монет(ids) таким же. Если минута не прошла и список не поменялся, то запрос не выполняется, а возвращаются старые монеты


final class APICaller {
    
    public static let shared = APICaller()
    
    private var lastCoinsMapUpdate: Date? {
        get { UserDefaults.standard.object(forKey: "lastCoinsMapUpdate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastCoinsMapUpdate") }
    }
    
    private let day: TimeInterval = 60 * 60 * 24 // seconds * minutes * hours
    
    private struct Constants {
        static let mapUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" // список всех монет
        static let listingUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest" // топ монет с котировками
        static let quotesUrl = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest" // котировки монет по ID
        
        static let apiKey = "c4dbc3af-5dd2-434a-87f2-d8f22f1b5f34"
        static let baseURL = "https://pro-api.coinmarketcap.com/v1/"
        static let headers: HTTPHeaders = ["Accepts": "application/json",
                                           "X-CMC_PRO_API_KEY": apiKey]
    }
    
    private init() {}
    
    //MARK: - Public
    
    public func fetchAllCoins() {
        
        if timeToUpdateMap() {
            AF.request(Constants.mapUrl,
                       method: .get,
                       parameters: nil,
                       headers: Constants.headers).responseDecodable(of: MapResponse.self) { response in
                
                switch response.result {
                case .success(let data):
                    let sortedCoins = data.data.sorted(by: {$0.rank < $1.rank} )
                    PersistenceManager.shared.coinsMap = sortedCoins
                    self.lastCoinsMapUpdate = Date()
                    print("Загружаем монеты")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // В MarketsVC добавить collectionView с кнопками для запроса с другой сортировкой - наибольший рост, падение, дата добавления.
    // Enum для queryParam с вариантами ?
    // queryParams ["sort": "", "sort_dir": "asc"(desc)] // market_cap (default), date_added, percent_change_24h, percent_change_7d
    public func fetchListing(queryParams: [String: String],
                             completion: @escaping (([CoinListingData]) -> Void)) {
        
        AF.request(Constants.listingUrl,
                   method: .get,
                   parameters: queryParams, // ["limit": "100"]
                   headers: APICaller.Constants.headers).responseDecodable(of: ListingResponse.self) { response in
            
            switch response.result {
            case .success(let data):
                completion(data.data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func fetchQuotes(ids: [Int],
                            completion: @escaping (([CoinListingData]) -> Void)) {
        let strIds = ids.map { String($0) }.joined(separator: ",")
        
        AF.request(Constants.quotesUrl,
                   method: .get,
                   parameters: ["id": strIds],
                   headers: APICaller.Constants.headers).responseDecodable(of: QuotesResponse.self) { response in
            
            switch response.result {
            case .success(let data):
                var sortedFavoriteCoins = [CoinListingData]()
                for id in ids { // сортировка, чтобы вернуть список монет в том же порядке, что и полученные IDs
                    for respCoin in data.data.values {
                        if id == respCoin.id {
                            sortedFavoriteCoins.append(respCoin)
                        }
                    }
                }
                completion(sortedFavoriteCoins)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: - Private
    
    private func timeToUpdateMap() -> Bool { // небольшое ограничение на обновление раз в 6 часов, чтобы снизить количество запросов
        let today = Date()
        if today - (day/4) >= lastCoinsMapUpdate ?? (today - day * 2) { // 11:00 12.08 >= 15:00 12.08
            print("Время обновить")
            return true
        } else {
            print("Рано обновлять. Последнее обновление:", lastCoinsMapUpdate ?? "")
            return false
        }
    }
}
