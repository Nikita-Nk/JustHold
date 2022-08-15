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
        static let infoUrl = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info" // https://pro-api.coinmarketcap.com/v2/cryptocurrency/info?aux=logo%2Cdescription&id=1%2C2
        // Пример - https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=5000&convert=USD
        
        static let apiKey = "c4dbc3af-5dd2-434a-87f2-d8f22f1b5f34"
        static let baseURL = "https://pro-api.coinmarketcap.com/v1/"
        static let headers: HTTPHeaders = ["Accepts": "application/json",
                                           "X-CMC_PRO_API_KEY": apiKey]
    }
    
    private init() {}
    
    //MARK: - Public
    
    public func getAllCoins() {
        
        if isTimeToUpdate() {
            AF.request(Constants.mapUrl,
                       method: .get,
                       parameters: nil,
                       headers: Constants.headers).responseDecodable(of: MapResponse.self) { response in
                
                let sortedCoins = response.value!.data.sorted(by: {$0.rank < $1.rank} )
                PersistenceManager.shared.coinsMap = sortedCoins
                
                self.lastCoinsMapUpdate = Date()
                print("Загружаем монеты")
            }
        }
    }
    
    //MARK: - Private
    
    private func isTimeToUpdate() -> Bool {
        let today = Date()
        if today - day >= lastCoinsMapUpdate ?? (today - day * 2) { // 11:00 12.08 >= 15:00 12.08
            print("Время обновить")
            return true
        } else {
            print(lastCoinsMapUpdate)
            print(today)
            print("Рано обновлять")
            return false
        }
    }
    
    
    
    private enum Endpoint: String {
        case cryptocurrency // = "cryptocurrency" (если использовать значение.rawValue) // возвращают данные о криптовалютах, такие как упорядоченные списки криптовалют или данные о ценах и объемах.
        case exchange // ordered exchange lists and market pair data
//        case global-metrics // global market cap and BTC dominance.
        case tools // cryptocurrency and fiat price conversions.
    }
    
    // Cryptocurrency and exchange endpoints provide 2 different ways of accessing data depending on purpose
    // */listings/* - endpoints allow you to sort and filter lists of data like cryptocurrencies by market cap or exchanges by volume.
    // Item endpoints (*/market-pairs/*) -
    
    // Endpoint paths follow a pattern matching the type of data provided
    // */latest - Latest market ticker quotes and averages for cryptocurrencies and exchanges
    // */historical - Intervals of historic market data like OHLCV data or data for use in charting libraries.
    // */info - Cryptocurrency and exchange metadata like block explorer URLs and logos
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
