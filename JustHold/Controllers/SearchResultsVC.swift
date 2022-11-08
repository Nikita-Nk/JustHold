import UIKit
import FloatingPanel

final class SearchResultsVC: UIViewController {
    
    private var results: [CoinMapData] = []
    
    public var titleForHeader: String?
    
    public let floatingPanel = FloatingPanelController()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchResultTableViewCell.self,
                       forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
        setUpFloatingPanel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.snp.top).offset(60)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Public
    
    public func update(with results: [CoinMapData]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
    
    //MARK: - Private
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpFloatingPanel() {
        floatingPanel.delegate = self
        floatingPanel.isRemovalInteractionEnabled = true
        floatingPanel.hide()
    }
}

//MARK: - UITableViewDelegate

extension SearchResultsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coin = results[indexPath.row]
        PersistenceManager.shared.addToLatestSearches(coin: coin)
        
        let chooseSymbolVC = ChooseSymbolVC()
        chooseSymbolVC.coinID = coin.id
        PersistenceManager.shared.searchInSymbols(coinSymbol: coin.symbol) { symbols in
            chooseSymbolVC.symbols = symbols
        }
        floatingPanel.dismiss(animated: false)
        floatingPanel.set(contentViewController: chooseSymbolVC)
        floatingPanel.addPanel(toParent: self)
        floatingPanel.hide()
        floatingPanel.show(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension SearchResultsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier,
                                                       for: indexPath) as? SearchResultTableViewCell else {
            return SearchResultTableViewCell()
        }
        
        let coin = results[indexPath.row]
        cell.configure(with: coin)
        
        return cell
    }
}

//MARK: - FloatingPanelControllerDelegate

extension SearchResultsVC: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        return location.y > view.height * 0.6 ? true : false
    }
}
