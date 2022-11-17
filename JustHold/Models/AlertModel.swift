import UIKit
import RealmSwift

final class AlertModel: Object {
    
    enum Condition: String, Codable {
        case greaterThan = "Больше, чем"
        case lessThan = "Меньше, чем"
    }
    
    @Persisted var id: Int = 0
    var logoUrl: String {
        return "https://s2.coinmarketcap.com/static/img/coins/64x64/\(id).png"
    }
    
    @Persisted var coinSymbolFinnhub: String = ""
    @Persisted var coinName: String = ""
    
    @Persisted var priceConditionString = Condition.greaterThan.rawValue
    var priceCondition: Condition {
        get { return Condition(rawValue: priceConditionString) ?? .greaterThan }
        set { priceConditionString = newValue.rawValue }
    }
    @Persisted var priceTarget: Double = 0
    @Persisted var notifyJustOnce: Bool = true
    @Persisted var pushNotificationsEnabled: Bool = false
    @Persisted var expirationDate: Date = Date()
    @Persisted var expirationDateDisabled: Bool = false
    @Persisted var alertName: String = ""
    @Persisted var alertMessage: String?
    
    @Persisted var isAlertActive: Bool = true
    @Persisted var didConditionMatchAfterLastCheck: Bool = false
    
    init(id: Int, coinSymbolFinnhub: String, coinName: String, priceTarget: Double, alertName: String) {
        self.id = id
        self.coinSymbolFinnhub = coinSymbolFinnhub
        self.coinName = coinName
        self.priceTarget = priceTarget
        self.alertName = alertName
    }
    
    override init() {
    }
}
