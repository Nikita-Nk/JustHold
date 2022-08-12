import Foundation

//public enum UserDefaultsKeys: String {
//    case login = "LoginKey"
//    case record = "RecordKey"
//    case userAge = "UserAge"
//    case appTheme = "AppTheme"
//}

//extension UserDefaults {
//    func setValue(_ value: Any?, forKey key: UserDefaultsKeys) {
//        setValue(value, forKey: key.rawValue)
//    }
//    func value(forKey key: UserDefaultsKeys) -> Any? { value(forKey: key.rawValue)
//    }
//}


//    public var coinsMap: [CoinData] { // чтобы сохранить в userDefaults, надо Codable использовать
//        get { userDefaults.value(forKey: "coinsMap") as! [CoinData] }
//        set { userDefaults.set(newValue, forKey: "coinsMap") }
//    }
    
    // Проверка последнего обновления
//    public var coinsUpdateDate: Date?
//    public let day: TimeInterval = 60 * 60 * 24 // seconds * minutes * hours
//    public func checkInspirationDate() {
//        let today = Date()
//        if (coinsUpdateDate ?? today) + day > today {
//            print("Рано обновлять")
//        }
//    }


final class PersistanceManager {
    
    static let shared = PersistanceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private init() {}
    
    //MARK: - Public
    
    public var coinsMap = [CoinData]()
    
    public func isCoinInCoinsMap(query: String,
                                 completion: @escaping ([CoinData]) -> Void) {
        var coins = [CoinData]()
        
        for coin in self.coinsMap {
            if coin.symbol.lowercased() == query {
                coins.insert(coin, at: 0)
            }
            else if coin.name.lowercased() == query {
                coins.insert(coin, at: 0)
            }
            else if coin.symbol.lowercased().contains(query) {
                coins.append(coin)
            }
            else if coin.name.lowercased().contains(query) {
                coins.append(coin)
            }
        }
        
        coins.sort(by: {$0.rank < $1.rank})
        completion(coins)
    }
    
    //MARK: - Private
    
}
