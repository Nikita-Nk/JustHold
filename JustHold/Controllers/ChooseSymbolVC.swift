import UIKit
import SnapKit
import RAMAnimatedTabBarController

class ChooseSymbolVC: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell") // Достаточно стандартного оформления ячейки
        return table
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Выберите пару"
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    public var symbols = [Symbol]()
    public var coinID: Int = 1
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableAndLabel()
        view.addSubview(label)
        view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.snp.makeConstraints { make in
            make.topMargin.equalTo(view.snp.topMargin).offset(90)
            make.leftMargin.rightMargin.bottomMargin.equalTo(view.layoutMarginsGuide)
        }
        label.snp.makeConstraints { make in
            make.topMargin.equalTo(view.snp.topMargin).inset(30)
            make.leftMargin.rightMargin.equalTo(view.layoutMarginsGuide).inset(5)
            make.height.equalTo(50)
        }
    }
    
    //MARK: - Private
    
    private func setUpTableAndLabel() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .secondarySystemBackground
        tableView.separatorColor = .secondaryLabel
        
        if symbols.isEmpty {
            label.text = "Нет доступных пар"
        }
    }
}

extension ChooseSymbolVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .secondarySystemBackground
        let symbol = symbols[indexPath.row]
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = symbol.description
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let symbol = symbols[indexPath.row]
        PersistenceManager.shared.lastChosenSymbol = symbol.symbol
        PersistenceManager.shared.lastChosenID = coinID
        
        NotificationCenter.default.post(name: Notification.Name("switchToChartVC"), object: nil)
    }
}
