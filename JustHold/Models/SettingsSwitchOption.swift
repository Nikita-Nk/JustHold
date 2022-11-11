import UIKit

struct SettingsSwitchOption {
    let text: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let isOn: Bool
    let handler: (() -> Void)
}
