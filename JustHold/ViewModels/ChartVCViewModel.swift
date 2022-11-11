import UIKit

class ChartVCViewModel {
    
    private var lastChosenSymbol: String
    
    public var coinName: String
    public var coinID: Int
    public var coinRank: String
    public var logoURL: String
    public var symbolLabelText: String
    public var exchangeLabelText: String
    public var exchange: String
    public var isInFavorites: Bool
    public var candles = [Candle]()
    public var collectionViewCellViewModels = [MetricCollectionViewCellViewModel]()
    public var queryParams: (resolution: String, days: TimeInterval) = ("D", 365*2)
    public var isFirstAppearance = true
    public var selectedChartIndex = -1
    
    //MARK: - Init
    
    init() {
        if PersistenceManager.shared.lastChosenID == 0 {
            PersistenceManager.shared.lastChosenID = 1
        }
        coinName = ""
        coinRank = ""
        logoURL = ""
        symbolLabelText = ""
        exchangeLabelText = ""
        
        
        let coins = PersistenceManager.shared.coinsMap
        coinID = PersistenceManager.shared.lastChosenID
        if coinID != PersistenceManager.shared.lastChosenID {
            isFirstAppearance = true
        }
        isInFavorites = PersistenceManager.shared.isInFavorites(coinID: coinID)
        
        let coinName2 = ""
        for coin in coins {
            if coin.id == coinID {
                coinName = coin.name
                coinRank = "\(coin.rank)"
                logoURL = coin.logoUrl
                break
            }
        }
        
        let cryptoSymbols = PersistenceManager.shared.cryptoSymbols
        lastChosenSymbol = PersistenceManager.shared.lastChosenSymbol
        exchange = lastChosenSymbol.components(separatedBy: ":")[0]
        for symbol in cryptoSymbols {
            if symbol.symbol == lastChosenSymbol {
                symbolLabelText = symbol.displaySymbol
                exchangeLabelText = coinName2 + "\n" + (symbol.description.components(separatedBy: " ").first ?? "")
                break
            }
        }
    }
    
    //MARK: - Public
    
    public func prepareAllData(completion: @escaping (Bool) -> Void) {
        let coins = PersistenceManager.shared.coinsMap
        if coinID != PersistenceManager.shared.lastChosenID {
            isFirstAppearance = true
        }
        coinID = PersistenceManager.shared.lastChosenID
        isInFavorites = PersistenceManager.shared.isInFavorites(coinID: coinID)
        
        for coin in coins {
            if coin.id == coinID {
                coinName = coin.name
                coinRank = "\(coin.rank)"
                logoURL = coin.logoUrl
            }
        }
        
        let cryptoSymbols = PersistenceManager.shared.cryptoSymbols
        lastChosenSymbol = PersistenceManager.shared.lastChosenSymbol
        exchange = lastChosenSymbol.components(separatedBy: ":")[0]
        for symbol in cryptoSymbols {
            if symbol.symbol == lastChosenSymbol {
                symbolLabelText = symbol.displaySymbol
                exchangeLabelText = coinName + "\n" + (symbol.description.components(separatedBy: " ").first ?? "")
            }
        }
        
        fetchFinancialData { isSuccess in
            completion(isSuccess)
        }
    }
    
    public func fetchFinancialData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        APICaller.shared.fetchCandles(for: lastChosenSymbol,
                                      resolution: queryParams.resolution,
                                      numberOfDays: queryParams.days) { [weak self] response in
            defer {
                group.leave()
            }
            switch response.result {
            case .success(let response):
                self?.candles = []
                self?.candles = response.candles.reversed()
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            let candlesIsEmpty: Bool = self?.candles.isEmpty ?? false
            if !candlesIsEmpty {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    public func prepareCollectionViewData(chosenIndex: Int = -1, completion: () -> Void) {
        let lastCandleIndex = candles.count - 1
        var candle = candles[lastCandleIndex]
        
        if chosenIndex == -1 || chosenIndex > lastCandleIndex {
            // если стандартное значение, либо выбранный индекс больше индекса последней свечи, тогда просто оставляем последнюю свечу
        } else { // в остальных случаях показываем свечу по выбранному индексу
            candle = candles[chosenIndex]
        }
        
        let change = candle.close - candle.open
        let percentChange = ((candle.close-candle.open)/candle.open) * 100
        let sign = change > 0 ? "+" : ""
        let changeValue = "\(sign)\(change.prepareValue) (\(sign)\(percentChange.preparePercentChange)%)"
        let color: UIColor = change > 0 ? .systemGreen : .systemRed
        
        collectionViewCellViewModels = []
        collectionViewCellViewModels.append(.init(name: "ОТКР", value: candle.open.prepareValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: "ЗАКР", value: candle.close.prepareValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: "МАКС", value: candle.high.prepareValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: "МИН", value: candle.low.prepareValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: "ИЗМ", value: changeValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: "ОБЪЁМ", value: candle.volume.prepareValue, valueColor: color))
        collectionViewCellViewModels.append(.init(name: candle.date.toString(dateFormat: "d MMM yyyy HH:mm"), value: "", valueColor: color))
        
        completion()
    }
    
    public func resolutionDidChange(index: Int, completion: () -> Void) {
        switch index {
        case 0:
            queryParams = (resolution: "1", days: 3)
        case 1:
            queryParams = (resolution: "5", days: 10)
        case 2:
            queryParams = (resolution: "15", days: 30)
        case 3:
            queryParams = (resolution: "60", days: 90)
        case 4:
            queryParams = (resolution: "D", days: 365*2)
        case 5:
            queryParams = (resolution: "W", days: 365*4)
        case 6:
            queryParams = (resolution: "M", days: 365*6)
        default:
            queryParams = (resolution: "D", days: 365*2)
        }
        completion()
    }
}
