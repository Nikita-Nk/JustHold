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
    
    public func update(with results: [CoinData]) { // вызываем в SearchController (MarketsVC) и передаем данные сюда, в SearchResultsVC
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
        var coin = results[indexPath.row]
        
        
        // ? Это надо? Данные же решил передавать во 2-ую вкладку, а не в MarketsVC
        delegate?.searchResultsVCdidSelect(coin: coin) // Выше создали protocol и weak delegate. func из protocol. Тут функцию вызываем, чтобы передать данные в MarketsVC. А описание функции в MarketsVC
    }
}
