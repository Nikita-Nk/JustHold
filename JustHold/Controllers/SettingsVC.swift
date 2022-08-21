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

//MARK: - UIViewController

class SettingsVC: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped) // insetGrouped - у ячеек отступ по бокам и углы секций скруглены
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        return table
    }()
    
    private var sections = [Section]()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Настройки" // в tabBar появляется вторая надпись "Настройки", а не только сверху
        navigationController?.title = "" // Это нужно, чтобы убрать именно из tabBar надпись, а сверху заголовок останется
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        setUpTable()
        configureSections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Private
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureSections() {
        let backgroundColor = UIColor.clear
        
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
                isOn: self.traitCollection.userInterfaceStyle == .dark ? true : false,
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
        
        sections.append(Section(title: "Безопасность", options: [
            .switchCell(model: SettingsSwitchOption(
                text: text,
                icon: UIImage(systemName: icon),
                iconBackgroundColor: backgroundColor,
                isOn: PersistenceManager.shared.securityIsOn,
                handler: {
                    PersistenceManager.shared.securityIsOn.toggle()
                }))
        ]))
    }
}

//MARK: - UITableViewDelegate

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let titleView = view as! UITableViewHeaderFooterView
        titleView.textLabel?.text = titleView.textLabel?.text?.capitalized // чтобы заголовок был не Капсом
        titleView.textLabel?.textColor = .label
        titleView.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier,
                                                     for: indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier,
                                                     for: indexPath) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let model = sections[indexPath.section].options[indexPath.row]
        switch model.self {
        case .staticCell(_):
            return indexPath
        case .switchCell(_): // делаем ячейки со Switch не кликабельными
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateSlightly()
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .staticCell(let model):
            model.handler() // выполняем действие, которое прописали выше в handler у всех элементов
        case .switchCell(let model):
            model.handler() // тут не сработает, т.к. чуть выше сделал не кликабельными switch-ячейки
        }
    }
}
