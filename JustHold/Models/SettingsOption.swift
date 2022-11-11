import UIKit

struct SettingsOption {
    let text: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}
