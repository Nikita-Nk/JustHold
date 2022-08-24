import UIKit
import FloatingPanel

class SearchResultsVC: UIViewController {
    
    private var results: [CoinMapData] = []
    
    public var titleForHeader: String?
    
    public var offsetForTableView: CGFloat?
    
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
        tableView.frame = view.bounds
        tableView.frame.origin.y = offsetForTableView ?? 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Public
    
    public func update(with results: [CoinMapData]) { // вызываем в SearchController (MarketsVC) и передаем данные сюда, в SearchResultsVC
        self.results = results
        tableView.isHidden = results.isEmpty // if isEmpty, tableView isHidden
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

extension SearchResultsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultTableViewCell.preferredHeight
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coin = results[indexPath.row]
        PersistenceManager.shared.addToLatestSearches(coin: coin)
        
        let contentVC = ChooseSymbolVC()
        PersistenceManager.shared.searchInSymbols(coinSymbol: coin.symbol) { symbols in
            contentVC.symbols = symbols
        }
        floatingPanel.dismiss(animated: false)
        floatingPanel.set(contentViewController: contentVC)
        floatingPanel.addPanel(toParent: self)
        floatingPanel.hide()
        floatingPanel.show(animated: true, completion: nil)
    }
}

//MARK: - FloatingPanelControllerDelegate

extension SearchResultsVC: FloatingPanelControllerDelegate {
}
