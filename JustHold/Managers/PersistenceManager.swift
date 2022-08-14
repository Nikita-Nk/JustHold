import UIKit

final class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private struct Constants {
        static let coinsMap = "coinsMap"
        static let favoriteCoins = "favoriteCoins"
    }
    
    private init() {}
    
    //MARK: - Public
    
    public var coinsMap: [CoinData] {
        get { getDataFromUserD(key: Constants.coinsMap) }
        set { saveCoins(array: newValue, key: Constants.coinsMap) }
    }
    
    public var favoriteCoins: [CoinData] { // Или лучше использовать [CoinData]? без инициализации в AppDelegate? Тогда ?? []
        get { getDataFromUserD(key: Constants.favoriteCoins) }
        set { saveCoins(array: newValue, key: Constants.favoriteCoins) }
    }
    
    public func isInCoinsMap(query: String,
                                 completion: @escaping ([CoinData]) -> Void) {
        var coins = [CoinData]()
        
        for coin in self.coinsMap {
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
    
    public func removeFromFavorites(coin: CoinData) {
        var newList = [CoinData]()
        for item in favoriteCoins where item != coin {
            newList.append(item)
        }
        favoriteCoins = newList
    }
    
    //MARK: - Private
    
    private func saveCoins(array: [CoinData], key: String) {
        do {
            let coinsArray = try encoder.encode(array)
            UserDefaults.standard.set(coinsArray, forKey: key)
        } catch {
            print(error)
        }
    }
    
    private func getDataFromUserD(key: String) -> [CoinData] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return coinsMap }
        do {
            let coinsArray = try decoder.decode([CoinData].self, from: data)
            return coinsArray
        } catch {
            print(error)
        }
        return coinsMap
    }
}
