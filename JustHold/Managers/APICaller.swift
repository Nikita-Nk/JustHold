import UIKit
import Alamofire

final class APICaller {
    
    public static let shared = APICaller()
    
    private var lastCoinsMapUpdate: Date? {
        get { UserDefaults.standard.object(forKey: "lastCoinsMapUpdate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastCoinsMapUpdate") }
    }
    
    private var lastSymbolsUpdate: Date? {
        get { UserDefaults.standard.object(forKey: "lastSymbolsUpdate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastSymbolsUpdate") }
    }
    
    private struct Constants {
        static let day: TimeInterval = 60 * 60 * 24 // seconds * minutes * hours
        static let mapUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map" // список всех монет
        static let listingUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest" // топ монет с котировками
        static let quotesUrl = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest" // котировки монет по ID
        static let exchangeSymbolsUrl = "https://finnhub.io/api/v1/crypto/symbol"
        static let candlesUrl = "https://finnhub.io/api/v1/crypto/candle"
        
        static let apiKeyFinnhub = "cb5rid2ad3i0dk7b9ca0"
        static let apiKey = "c4dbc3af-5dd2-434a-87f2-d8f22f1b5f34"
        static let baseURL = "https://pro-api.coinmarketcap.com/v1/"
        static let headers: HTTPHeaders = ["Accepts": "application/json",
                                           "X-CMC_PRO_API_KEY": apiKey]
    }
    
    private init() {}
    
    //MARK: - Public
    
    public func fetchCoinsMap() {
        guard timeToUpdate(date: lastCoinsMapUpdate) else {
            return
        }
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
    
    //MARK: - Public Finnhub
    
    public func fetchAllSymbols() {
        guard timeToUpdate(date: lastSymbolsUpdate) else {
            return
        }
        let exchanges = ["Binance", "COINBASE", "KRAKEN", "KUCOIN", "BITFINEX", "GEMINI", "HUOBI", "POLONIEX", "BITTREX"] // "ZB", "OKEX"
        let updatedSymbols = [Symbol]()
        
        for exchange in exchanges {
            let queryParams = ["exchange": exchange, "token": Constants.apiKeyFinnhub]
            
            AF.request(Constants.exchangeSymbolsUrl,
                       method: .get,
                       parameters: queryParams,
                       headers: nil).responseDecodable(of: [Symbol].self) { response in
                
                switch response.result {
                case .success(let symbols):
                    PersistenceManager.shared.cryptoSymbols += symbols
                case .failure(let error):
                    print(error)
                }
            }
        }
        PersistenceManager.shared.cryptoSymbols = updatedSymbols
        self.lastSymbolsUpdate = Date()
    }
    
    public func fetchCandles(for symbol: String = "BINANCE:BTCUSDT",
                             resolution: String = "D", // 1, 5, 15, 30, 60, D, W, M - таймфрейм
                             numberOfDays: TimeInterval = 7,
                             completion: @escaping (CandlesData) -> Void) {
        let today = Date()
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        
        let queryParams = ["symbol": symbol,
                           "resolution": resolution,
                           "from": "\(Int(prior.timeIntervalSince1970))",
                           "to": "\(Int(today.timeIntervalSince1970))",
                           "token": Constants.apiKeyFinnhub]
        
        AF.request(Constants.candlesUrl,
                   method: .get,
                   parameters: queryParams,
                   headers: nil).responseDecodable(of: CandlesData.self) { response in

            switch response.result {
            case .success(let candles):
                completion(candles)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: - Private
    
    private func timeToUpdate(date: Date?) -> Bool { // небольшое ограничение на обновление раз в 6 часов, чтобы снизить количество запросов
        let today = Date()
        if today - (Constants.day/4) >= date ?? (today - Constants.day * 2) { // 11:00 12.08 >= 15:00 12.08
            print("Время обновить")
            return true
        } else {
            print("Рано обновлять. Последнее обновление:", date ?? "")
            return false
        }
    }
}
