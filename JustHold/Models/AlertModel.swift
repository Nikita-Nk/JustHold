import UIKit

struct AlertModel: Codable {
    
    enum Condition: String, Codable {
        case greaterThan = "Больше, чем"
        case lessThan = "Меньше, чем"
    }
    
    let id: Int
    lazy var logoUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/\(id).png"
    let coinSymbolFinnhub: String
    let coinName: String
    
    var priceCondition: Condition = .greaterThan
    var priceTarget: Double
    var notifyJustOnce: Bool = true
    var pushNotificationsEnabled: Bool = false
    var expirationDate: Date = Date()
    var expirationDateDisabled: Bool = false
    var alertName: String
    var alertMessage: String?
    
    var isAlertActive: Bool = true
    var didConditionMatchAfterLastCheck: Bool = false
}
