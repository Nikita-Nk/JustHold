import UIKit

struct AddAlertVCViewModel {
    
    enum Purpose: String, Codable {
        case saveNewAlert = "Сохранить"
        case editExistingAlert = "Изменить"
    }
    
    var alert: AlertModel
    var purpose: Purpose
    let saveButtonText: String
    var canAutoupdateAlertName = true
    
    init(purpose: Purpose, coinQuote: CoinListingData, candles: [Candle], coinSymbol: String) {
        alert = .init(id: coinQuote.id,
                      coinSymbolFinnhub: coinSymbol,
                      coinName: coinQuote.name,
                      priceTarget: candles.last?.close ?? 0,
                      alertName: "")
        self.purpose = purpose
        saveButtonText = purpose.rawValue
    }
    
    init(purpose: Purpose, alert: AlertModel) {
        self.alert = alert
        self.purpose = purpose
        saveButtonText = purpose.rawValue
    }
}
