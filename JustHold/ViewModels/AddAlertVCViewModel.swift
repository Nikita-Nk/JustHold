import UIKit

struct AddAlertVCViewModel {
    
    var alert: AlertModel
    var purpose: Purpose
    let saveButtonText: String
    var canAutoupdateAlertName = true
    
    init(purpose: Purpose, coinName: String, candles: [Candle]) {
        alert = .init(id: PersistenceManager.shared.lastChosenID,
                      coinSymbolFinnhub: PersistenceManager.shared.lastChosenSymbol,
                      coinName: coinName,
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

// MARK: - Nested Types

extension AddAlertVCViewModel {
    
    enum Purpose: String, Codable {
        case saveNewAlert = "Сохранить"
        case editExistingAlert = "Изменить"
    }
}
