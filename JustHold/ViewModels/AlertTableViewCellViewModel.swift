import UIKit
import RealmSwift

struct AlertTableViewCellViewModel {
    
    let alert: AlertModel
    let expirationText: String
    let isSwitchControlOn: Bool
    let isBellViewHidden: Bool
    let nameLabelText: String
    
    init(_ alert: AlertModel) {
        self.alert = alert
        
        if alert.expirationDateDisabled {
            expirationText = "\(alert.coinName)  •  Без срока истечения"
        } else {
            expirationText = "\(alert.coinName)  •  Истекает " + alert.expirationDate.toString(dateFormat: "dd MMM HH:mm")
        }

        if !alert.expirationDateDisabled && alert.expirationDate < Date() {
            isSwitchControlOn = false
            try! Realm().write {
                alert.isAlertActive = false
            }
        } else {
            isSwitchControlOn = alert.isAlertActive ? true : false
        }

        isBellViewHidden = !alert.didConditionMatchAfterLastCheck
        nameLabelText = alert.alertName
    }
}
