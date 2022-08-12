import UIKit

protocol SearchResultsVCDelegate: AnyObject {
    
    func searchResultsVCdidSelect(searchResult: SearchResult)
}

class SearchResultsVC: UIViewController {
    
    weak var delegate: SearchResultsVCDelegate?
    
    private var results: [SearchResult] = []
    
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
    
    public func update(with results: [SearchResult]) { // с помощью этой функции передаем результаты поиска из SearchController (MarketsVC) сюда, в SearchResultsVC
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
        let model = results[indexPath.row]
        cell.textLabel?.text = model.displaySymbol
        cell.detailTextLabel?.text = model.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.searchResultsVCdidSelect(searchResult: model) // Выше создали protocol и weak delegate. func из protocol. Тут функцию вызываем, чтобы передать данные в MarketsVC. А описание функции в MarketsVC
    }
}
