import Foundation

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

// MARK: - Nested Types

extension Section {
    enum SettingsOptionType {
        case staticCell(model: SettingsOption)
        case switchCell(model: SettingsSwitchOption)
    }
}
