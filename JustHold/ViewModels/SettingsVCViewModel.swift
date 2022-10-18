import UIKit
import LocalAuthentication

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsOption {
    let text: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

struct SettingsSwitchOption {
    let text: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let isOn: Bool
    let handler: (() -> Void)
}

struct SettingsVCViewModel {

    public var sections = [Section]()

    //MARK: - Init

    init() {
        self.sections = prepareSections()
    }

    //MARK: - Private
    
    private func prepareSections() -> [Section]{
        let backgroundColor = UIColor.clear
        var sections = [Section]()

        sections.append(Section(title: "Поддержать проект", options: [
            .staticCell(model: SettingsOption(
                text: "Оценить приложение",
                icon: UIImage(systemName: "star"),
                iconBackgroundColor: backgroundColor,
                handler: {
                    print("Оценить приложение")
                    HapticsManager.shared.vibrateSlightly()
                }))
        ]))

        sections.append(Section(title: "Оформление", options: [
            .switchCell(model: SettingsSwitchOption(
                text: "Тёмная тема",
                icon: UIImage(systemName: "paintpalette"),
                iconBackgroundColor: backgroundColor,
                isOn: PersistenceManager.shared.darkModeIsOn ? true : false,
                handler: {
                    NotificationCenter.default.post(name: Notification.Name("switchToDark"), object: nil)
                })),
            .switchCell(model: SettingsSwitchOption(
                text: "Тёмная тема для графиков",
                icon: UIImage(systemName: "paintbrush"),
                iconBackgroundColor: backgroundColor,
                isOn: false,
                handler: {
                    print("Вкл/Выкл темную тему для графиков")
                }))
        ]))

        let biometric: (text: String, icon: String) = getBiometricType()
        sections.append(Section(title: "Безопасность", options: [
            .switchCell(model: SettingsSwitchOption(
                text: biometric.text,
                icon: UIImage(systemName: biometric.icon),
                iconBackgroundColor: backgroundColor,
                isOn: PersistenceManager.shared.securityIsOn,
                handler: {
                    PersistenceManager.shared.securityIsOn.toggle()
                }))
        ]))
        
        return sections
    }
    
    private func getBiometricType() -> (String, String) {
        let currentBiometricType = LAContext().biometricType
        var text = ""
        var icon = ""

        switch currentBiometricType {
        case .none:
            text = "Пароль"
            icon = "lock"
        case .touchID:
            text = "Touch ID"
            icon = "touchid"
        case .faceID:
            text = "Face ID"
            icon = "faceid"
        }
        return (text, icon)
    }
}
