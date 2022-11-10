import UIKit

final class SettingsVC: UIViewController {
    
    private let viewModel = SettingsVCViewModel()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.register(SettingsTableFooterView.self, forHeaderFooterViewReuseIdentifier: SettingsTableFooterView.identifier)
        return table
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Настройки"
        navigationController?.title = ""
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        setUpTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .playPortfolioAnimation, object: nil)
    }
    
    //MARK: - Private
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - UITableViewDelegate

extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let titleView = view as? UITableViewHeaderFooterView else { return }
        titleView.textLabel?.text = titleView.textLabel?.text?.capitalized
        titleView.textLabel?.textColor = .label
        titleView.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let model = viewModel.sections[indexPath.section].options[indexPath.row]
        switch model.self {
        case .staticCell(_):
            return indexPath
        case .switchCell(_): // при нажатии на switch-ячейку, действие из handler не выполнится
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateSlightly()
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel.sections[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .staticCell(let model):
            model.handler() // выполняем действие, которое прописали выше в handler у всех элементов
        case .switchCell(let model):
            model.handler() // тут не сработает, т.к. чуть выше сделал не кликабельными switch-ячейки
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == viewModel.sections.count - 1 else {
            return nil
        }
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsTableFooterView.identifier)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == viewModel.sections.count - 1 ? view.width*0.75 : 10
    }
}

//MARK: - UITableViewDataSource

extension SettingsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.sections[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.sections[indexPath.section].options[indexPath.row]
        
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
            cell.selectionStyle = .none // нажатие на switch-ячейку никак не отображается
            return cell
        }
    }
}
