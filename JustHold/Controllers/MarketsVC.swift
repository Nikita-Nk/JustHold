import UIKit
import RAMAnimatedTabBarController

class MarketsVC: UIViewController {
    
    private var searchTimer: Timer?
    
    private var coins: [CoinListingData] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MarketsTableViewCell.self,
                       forCellReuseIdentifier: MarketsTableViewCell.identifier)
        return table
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var canUpdateSearch = true
    
    private var favoritesAreHidden = true
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchListing()
        tableView.refreshControl = refreshControl
        view.backgroundColor = .systemBackground
        setUpTable()
        setUpNavigationBar()
        setupSearchController()
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged) // не срабатывает, либо выдает ошибку, если добавить выше в refreshControl
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        activityIndicator.center = view.center
    }
    
    //MARK: - Private
    
    @objc private func refresh(sender: UIRefreshControl) {
        favoritesAreHidden ? fetchListing() : fetchQuotes()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func favoritesTapped() {
        if favoritesAreHidden {
            favoritesAreHidden = false
            if let favButton = navigationItem.rightBarButtonItems?[0] {
                favButton.tintColor = .systemYellow
                favButton.image = UIImage(systemName: "star.slash.fill")
            }
            if let listButton = navigationItem.rightBarButtonItems?[1] {
                listButton.isEnabled = true
                listButton.tintColor = .systemBlue
            }
            if PersistenceManager.shared.favoriteCoinsIDs.isEmpty {
                tableView.isHidden = true
                return
            }
            fetchQuotes()
        }
        else {
            tableView.isHidden = false
            fetchListing()
            favoritesAreHidden = true
            if let favButton = navigationItem.rightBarButtonItems?[0] {
                favButton.tintColor = .systemBlue
                favButton.image = UIImage(systemName: "star")
            }
            if let listButton = navigationItem.rightBarButtonItems?[1] {
                listButton.isEnabled = false
                listButton.tintColor = .clear
            }
            if tableView.isEditing {
                tableView.isEditing = false
            }
        }
    }
    
    @objc private func didTapSort() {
        if tableView.isEditing {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
    
    private func fetchQuotes() {
        APICaller.shared.fetchQuotes(ids: PersistenceManager.shared.favoriteCoinsIDs) { quotes in
            self.coins = quotes
            self.tableView.reloadData()
        }
    }
    
    private func fetchListing() {
        APICaller.shared.fetchListing(queryParams: ["limit": "100"]) { [weak self] response in // weak self ?
            self?.coins = response
            self?.tableView.reloadData()
            self?.activityIndicator.stopAnimating()
        }
    }
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "star"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(favoritesTapped)),
                                              UIBarButtonItem(image: UIImage(systemName: "list.number"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(didTapSort))]
        if let listButton = navigationItem.rightBarButtonItems?[1] {
            listButton.isEnabled = false
            listButton.tintColor = .clear
        }
        let titleView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.width,
                                             height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10,
                                          y: 0,
                                          width: titleView.width - 20,
                                          height: titleView.height))
        label.text = "Криптовалюты"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    private func setupSearchController() {
        let searchResultsVC = SearchResultsVC()
        searchResultsVC.delegate = self // получаем данные из SearchResultsVC с помощью delegate. И ниже в extension прописываем функцию из protocol
        let searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchBar.placeholder = "Искать монеты"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self // для обработки "Cancel"
        navigationItem.searchController = searchController
        
        searchResultsVC.offsetForTableView = searchController.searchBar.height + (navigationItem.titleView?.height ?? 44) // Передаем отступ для tableView
    }
}

//MARK: - UITableViewDelegate

extension MarketsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none // remove the delete button ⛔️ on table rows in edit mode
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        PersistenceManager.shared.favoriteCoinsIDs.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketsTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketsTableViewCell.identifier,
                                                       for: indexPath) as? MarketsTableViewCell else {
            return MarketsTableViewCell()
        }
        let coin = coins[indexPath.row]
        cell.configure(with: coin)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // переписать переход на другую вкладку
        tableView.deselectRow(at: indexPath, animated: true)
//        let coin = coins[indexPath.row] // для передачи
        
        // Переход на другую вкладку TBC - сделать отдельную функцию и вызывать её здесь и в extension
        let currentIndex: Int? = self.tabBarController?.selectedIndex
        
        if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController,
           let current = currentIndex {
            ramTBC.setSelectIndex(from: current, to: 1)
        }
    }
}

//MARK: - UISearchBarDelegate

extension MarketsVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        canUpdateSearch = true
        tableView.isHidden = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        canUpdateSearch = false
        tableView.isHidden = false
        tableView.reloadData()
    }
}

//MARK: - UISearchResultsUpdating

extension MarketsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(),
              let searchResultsVC = searchController.searchResultsController as? SearchResultsVC,
              canUpdateSearch else {
            return
        }
        
        searchTimer?.invalidate() // сброс таймера. Дальше запускаем снова, чтобы оптимизировать ресурсы и кол-во запросов
//         На самом деле, сейчас не нужно, т.к. ищем по уже загруженному списку

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                searchController.searchResultsController?.view.isHidden = false // без этого tableView просто не будет отображаться до тех пор, пока не введу хоть какой-то символ

                searchResultsVC.titleForHeader = "Недавние поиски"
                searchResultsVC.update(with: PersistenceManager.shared.latestSearches)
            }
            else if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                searchResultsVC.titleForHeader = nil
                PersistenceManager.shared.searchInCoinsMap(query: query) { coins in
                    searchResultsVC.update(with: coins) // отправляем результаты поиска в searchResultsVC
                }
            }
        })
    }
}

//MARK: - SearchResultsVCDelegate - переделать

extension MarketsVC: SearchResultsVCDelegate { // Нужно для переключения вкладки TabBar
    
    func searchResultsVCdidSelect(coin: CoinMapData) {
        
        // Переход на другую вкладку TBC
        let currentIndex: Int? = self.tabBarController?.selectedIndex
        
        if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController,
           let current = currentIndex {
            ramTBC.setSelectIndex(from: current, to: 1)
        }
        
        // Передать coin? - https://developer.apple.com/forums/thread/119037
    }
}
