import UIKit

struct AlertModel: Codable {
    
    enum Condition: Codable {
        case greaterThan
        case lessThan
    }
    
    let isActive: Bool
    let lastNotificationDate: Date?
    
    let priceCondition: Condition
    let price: Double // Decimal?
    let notifyOnce: Bool
    let pushNotificationsEnabled: Bool
    let expirationDate: Date
    let expirationDateDisabled: Bool
    let name: String
    let message: String?
}
