import UIKit

protocol SearchResultsVCDelegate: AnyObject {
    
    func searchResultsVCdidSelect(coin: CoinData)
}

class SearchResultsVC: UIViewController {
    
    weak var delegate: SearchResultsVCDelegate?
    
    private var results: [CoinData] = []
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Public
    
    public func update(with results: [CoinData]) { // с помощью этой функции передаем результаты поиска из SearchController (MarketsVC) сюда, в SearchResultsVC
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
    
}

extension SearchResultsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        let coin = results[indexPath.row]
        cell.textLabel?.text = coin.symbol
        cell.detailTextLabel?.text = coin.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coin = results[indexPath.row]
        
        // добавляю в избранное / удаляю
        if PersistenceManager.shared.isInFavorites(coin: coin) {
            PersistenceManager.shared.removeFromFavorites(coin: coin)
            print(PersistenceManager.shared.favoriteCoins)
            print("удаляем")
        } else {
            PersistenceManager.shared.favoriteCoins.append(coin)
            print(PersistenceManager.shared.favoriteCoins)
            print("добавляем")
        }
        
        delegate?.searchResultsVCdidSelect(coin: coin) // Выше создали protocol и weak delegate. func из protocol. Тут функцию вызываем, чтобы передать данные в MarketsVC. А описание функции в MarketsVC
        
    }
}
