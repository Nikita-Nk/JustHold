import UIKit
import Alamofire

// Coinmarketcap dashboard with statistics - https://pro.coinmarketcap.com/account
// API documentation - https://coinmarketcap.com/api/documentation/v1/

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
        
        static let apiKey = "c4dbc3af-5dd2-434a-87f2-d8f22f1b5f34"
        static let baseURL = "https://pro-api.coinmarketcap.com/v1/"
        static let headers: HTTPHeaders = ["Accepts": "application/json",
                                           "X-CMC_PRO_API_KEY": apiKey]
    }
    
    private init() {}
    
    //MARK: - Public
    
    public func fetchAllCoins() {
        
        if isTimeToUpdate() {
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
                             completion: @escaping ((ListingResponse) -> Void)) { // или передавать сразу CoinListingData ?
        
        AF.request(Constants.listingUrl,
                   method: .get,
                   parameters: queryParams, // ["limit": "100"]
                   headers: APICaller.Constants.headers).responseDecodable(of: ListingResponse.self) { response in
            
            switch response.result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // fetchQuotes - инфо по конкретным монетам, queryParams
    // public func fetchQuotes()
    
    //MARK: - Private
    
    private func isTimeToUpdate() -> Bool { // небольшое ограничение на обновление раз в 6 часов, чтобы снизить количество запросов
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





// getInfo не надо, т.к. я могу сам ссылку создать без запроса
//    public func getInfo(ids: String) { // , completion: @escaping () -> Void)
//        var queryParams = ["id": ids,
//                           "aux": "logo"] // description - nil тогда
//        AF.request(Constants.infoUrl,
//                   method: .get,
//                   parameters: queryParams,
//                   headers: Constants.headers).responseDecodable(of: InfoResponse.self) { response in
//            print(response.value?.data["1"]?.logo) // лого элемента dictionary с key "1"
//        }
//    }
//
//// MARK: - InfoResponse
//struct InfoResponse: Codable {
//    let data: [String: Info] // String: Info
////    let status: Status
//}
//
//// MARK: - Info
//struct Info: Codable {
//    let logo: String
//    let id: Int
////    let description: String
//}
