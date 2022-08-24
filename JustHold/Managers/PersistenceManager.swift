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
        static let cryptoSymbols = "cryptoSymbols"
        static let lastChosenSymbol = "lastChosenSymbol"
    }
    
    private init() {}
    
    //MARK: - Public
    
    public var coinsMap: [CoinMapData] {
        get { getCoinsFromUserDefaults(key: Constants.coinsMap, type: [CoinMapData].self) }
        set { saveCoinsToUsedDefaults(array: newValue, key: Constants.coinsMap) }
    }
    
    public var favoriteCoinsIDs: [Int] {
        get { userDefaults.array(forKey: Constants.favoriteCoins) as? [Int] ?? [] }
        set { userDefaults.setValue(newValue, forKey: Constants.favoriteCoins) }
    }
    
    public var latestSearches: [CoinMapData] {
        get { getCoinsFromUserDefaults(key: Constants.latestSearches, type: [CoinMapData].self) }
        set { saveCoinsToUsedDefaults(array: newValue, key: Constants.latestSearches) }
    }
    
    public var cryptoSymbols: [Symbol] {
        get { getCoinsFromUserDefaults(key: Constants.cryptoSymbols, type: [Symbol].self) }
        set { saveCoinsToUsedDefaults(array: newValue, key: Constants.cryptoSymbols) }
    }
    
    public var darkModeIsOn: Bool {
        get { userDefaults.bool(forKey: Constants.darkModeIsOn) }
        set { userDefaults.set(newValue, forKey: Constants.darkModeIsOn) }
    }
    
    public var securityIsOn: Bool {
        get { userDefaults.bool(forKey: Constants.securityIsOn) }
        set { userDefaults.set(newValue, forKey: Constants.securityIsOn) }
    }
    
    public var lastChosenSymbol: String {
        get { userDefaults.string(forKey: Constants.lastChosenSymbol) ?? "BINANCE:BTCUSDT" }
        set { userDefaults.set(newValue, forKey: Constants.lastChosenSymbol) }
    }
    
    //MARK: - Public func
    
    public func searchInSymbols(coinSymbol: String, completion: @escaping ([Symbol]) -> Void) {
        var symbols = [Symbol]()
        let coinToSearch = coinSymbol.uppercased() + "/USDT"
        
        for symbol in cryptoSymbols {
            if symbol.displaySymbol == coinToSearch {
                symbols.append(symbol)
            } else if symbol.displaySymbol == "USDT/USD" {
                symbols.append(symbol)
            }
            // else if - можно добавить доп.проверки, чтобы выводить больше вариантов, например, пары с /ETH. И добавлять их в secondarySymbols
        }
        completion(symbols)
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
    
    private func saveCoinsToUsedDefaults<T: Encodable>(array: [T], key: String) {
        do {
            let coinsArray = try encoder.encode(array)
            UserDefaults.standard.set(coinsArray, forKey: key)
        } catch {
            print(error)
        }
    }
    
    private func getCoinsFromUserDefaults<T: Decodable>(key: String, type: [T].Type) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return type.init() }
        do {
            let coinsArray = try decoder.decode(type, from: data)
            return coinsArray
        } catch {
            print(error)
        }
        return type.init()
    }
}
