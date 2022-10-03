import UIKit

struct CalledAlertModel: Codable {
    let alertName: String
    let coinName: String
    let callDate: Date
    var isChecked: Bool = false
}
