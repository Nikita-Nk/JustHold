import Foundation
    
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
    
    public struct Constants {
        static let coinsMap = "coinsMap"
        static let favoriteCoins = "favoriteCoins"
    }
    
    private init() {}
    
    //MARK: - Public
    
//    public var coinsMap = [CoinData]()
//    public var favoriteCoins = [CoinData]()
    
    public var coinsMap: [CoinData] {
        get { CoinsArchiver.shared.getDataFromUserD(key: Constants.coinsMap) }
        set { CoinsArchiver.shared.saveCoins(array: newValue, key: Constants.coinsMap) }
    }
    
    public var favoriteCoins: [CoinData] {
        get { CoinsArchiver.shared.getDataFromUserD(key: Constants.favoriteCoins) }
        set { CoinsArchiver.shared.saveCoins(array: newValue, key: Constants.favoriteCoins) }
    }
    
    
    
    public func isInCoinsMap(query: String,
                                 completion: @escaping ([CoinData]) -> Void) {
        var coins = [CoinData]()
        
        for coin in self.coinsMap {
//            guard let coin = coin,
//                  coin.symbol.lowercased().contains(query),
//                  coin.name.lowercased().contains(query) else {
//                return
//            }
//            coins.append(coin)
            
//            guard let coin = coin else {
//                return
//            }
            
            if coin.symbol.lowercased().contains(query) || coin.name.lowercased().contains(query) {
                coins.append(coin)
            }
        }
        
        coins.sort(by: {$0.rank < $1.rank})
        completion(coins)
    }
    
    public func isInFavorites(coin: CoinData) -> Bool {
        return favoriteCoins.contains(coin)
    }
    
    public func addToFavorites(coin: CoinData) {
        var current = favoriteCoins
        current.append(coin)
        favoriteCoins = current
    }
    
    public func removeFromFavorites(coin: CoinData?) {
        var newList = [CoinData]()
        for item in favoriteCoins where item != coin {
//            guard let item = item else {
//                return
//            }
            newList.append(item)
        }
        favoriteCoins = newList
    }
    
    //MARK: - Private
    
}


final class CoinsArchiver { // Переместить функции выше в private и не делать отдельный Singletone ?
    
    static let shared = CoinsArchiver()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func saveCoins(array: [CoinData], key: String) {
        do {
            let coinsArray = try encoder.encode(array)
            UserDefaults.standard.set(coinsArray, forKey: key)
        } catch {
            print(error)
        }
    }
    
    func getDataFromUserD(key: String) -> [CoinData] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return PersistanceManager.shared.coinsMap }
        do {
            let coinsArray = try decoder.decode([CoinData].self, from: data)
            return coinsArray
        } catch {
            print(error)
        }
        return PersistanceManager.shared.coinsMap
    }
}
