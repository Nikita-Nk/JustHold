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
    
    public var coinsMap: [CoinMapData] {
        get { getDataFromUserD(key: Constants.coinsMap) }
        set { saveCoins(array: newValue, key: Constants.coinsMap) }
    }
    
    public var favoriteCoins: [Int] {
        get { userDefaults.array(forKey: Constants.favoriteCoins) as? [Int] ?? [] }
        set { userDefaults.setValue(newValue, forKey: Constants.favoriteCoins) }
    }
    
    public func searchInCoinsMap(query: String,
                                 completion: @escaping ([CoinMapData]) -> Void) {
        var coins = [CoinMapData]()
        
        for coin in self.coinsMap {
            if coin.symbol.lowercased().contains(query) || coin.name.lowercased().contains(query) {
                coins.append(coin)
            }
        }
        
        coins.sort(by: {$0.rank < $1.rank})
        completion(coins)
    }
    
    public func isInFavorites(coinID: Int) -> Bool {
        return favoriteCoins.map {$0 == coinID}.contains(true)
    }
    
    public func addToFavorites(coinID: Int) {
        favoriteCoins.append(coinID)
    }
    
    public func removeFromFavorites(coinID: Int) {
        favoriteCoins = favoriteCoins.filter { $0 != coinID}
    }
    
    //MARK: - Private
    
    private func saveCoins(array: [CoinMapData], key: String) {
        do {
            let coinsArray = try encoder.encode(array)
            UserDefaults.standard.set(coinsArray, forKey: key)
        } catch {
            print(error)
        }
    }
    
    private func getDataFromUserD(key: String) -> [CoinMapData] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return coinsMap }
        do {
            let coinsArray = try decoder.decode([CoinMapData].self, from: data)
            return coinsArray
        } catch {
            print(error)
        }
        return coinsMap
    }
}
