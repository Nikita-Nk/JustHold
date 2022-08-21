import UIKit

final class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private struct Constants {
        static let coinsMap = "coinsMap"
        static let favoriteCoins = "favoriteCoins"
        static let latestSearches = "latestSearches"
        static let darkModeIsOn = "darkModeIsOn"
        static let securityIsOn = "securityIsOn"
    }
    
    private init() {}
    
    //MARK: - Public
    
    public var coinsMap: [CoinMapData] {
        get { getDataFromUserD(key: Constants.coinsMap) }
        set { saveCoins(array: newValue, key: Constants.coinsMap) }
    }
    
    public var favoriteCoinsIDs: [Int] {
        get { userDefaults.array(forKey: Constants.favoriteCoins) as? [Int] ?? [] }
        set { userDefaults.setValue(newValue, forKey: Constants.favoriteCoins) }
    }
    
    public var latestSearches: [CoinMapData] {
        get { getDataFromUserD(key: Constants.latestSearches) }
        set { saveCoins(array: newValue, key: Constants.latestSearches) }
    }
    
    public var darkModeIsOn: Bool {
        get { userDefaults.bool(forKey: Constants.darkModeIsOn) }
        set { userDefaults.set(newValue, forKey: Constants.darkModeIsOn) }
    }
    
    public var securityIsOn: Bool {
        get { userDefaults.bool(forKey: Constants.securityIsOn) }
        set { userDefaults.set(newValue, forKey: Constants.securityIsOn) }
    }
    
    //MARK: - Public func
    
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
        return favoriteCoinsIDs.map {$0 == coinID}.contains(true)
    }
    
    public func addToFavorites(coinID: Int) {
        favoriteCoinsIDs.append(coinID)
    }
    
    public func removeFromFavorites(coinID: Int) {
        favoriteCoinsIDs = favoriteCoinsIDs.filter { $0 != coinID}
    }
    
    public func addToLatestSearches(coin: CoinMapData) {
        for (index, search) in latestSearches.enumerated() {
            if search.id == coin.id {
                latestSearches.remove(at: index)
            }
        }
        if latestSearches.count > 5 {
            latestSearches.removeLast()
        }
        latestSearches.insert(coin, at: 0)
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
        guard let data = UserDefaults.standard.data(forKey: key) else { return [CoinMapData]() }
        do {
            let coinsArray = try decoder.decode([CoinMapData].self, from: data)
            return coinsArray
        } catch {
            print(error)
        }
        return [CoinMapData]()
    }
}
