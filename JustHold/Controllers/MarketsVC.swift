import UIKit
import FloatingPanel
import RAMAnimatedTabBarController

final class MarketsVC: UIViewController {
    
    private var coins: [CoinListingData] = []
    
    private var canUpdateSearch = true
    
    private var favoritesAreHidden = true
    
    private var searchTimer: Timer?
    
    private lazy var searchResultsVC = SearchResultsVC()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(MarketsTableViewCell.self,
                       forCellReuseIdentifier: MarketsTableViewCell.identifier)
        return table
    }()
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var floatingPanel = FloatingPanelController()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchListing()
        tableView.refreshControl = refreshControl
        view.backgroundColor = .systemBackground
        setUpTable()
        fixTabBarVisualEffectBackdropView()
        setUpNavigationBar()
        setupSearchController()
        setUpFloatingPanel()
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToChartVC), name: .switchToChartVC, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        activityIndicator.center = view.center
    }
}

// MARK: - Private

private extension MarketsVC {
    
    @objc func refresh(sender: UIRefreshControl) {
        favoritesAreHidden ? fetchListing() : fetchQuotesForFavorites()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpFloatingPanel() {
        floatingPanel.delegate = self
        floatingPanel.isRemovalInteractionEnabled = true
        floatingPanel.hide()
    }
    
    @objc func switchToChartVC(_ notification: Notification) {
        let currentIndex: Int? = self.tabBarController?.selectedIndex
        if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController,
           let current = currentIndex {
            ramTBC.setSelectIndex(from: current, to: 1)
        }
    }
    
    @objc func favoritesTapped() {
        HapticsManager.shared.vibrateSlightly()
        floatingPanel.dismiss(animated: true)
        
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
            fetchQuotesForFavorites()
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
    
    @objc func didTapSort() {
        HapticsManager.shared.vibrate(for: .success)
        if tableView.isEditing {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
    
    func fetchQuotesForFavorites() {
        APICaller.shared.fetchQuotes(ids: PersistenceManager.shared.favoriteCoinsIDs) { quotes in
            self.coins = quotes
            self.tableView.reloadData()
        }
    }
    
    func fetchListing() {
        APICaller.shared.fetchListing(queryParams: ["limit": "100"]) { coins in
            self.coins = coins
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setUpNavigationBar() {
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
        label.text = "????????????????????????"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchBar.placeholder = "???????????? ????????????"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
}

//MARK: - UITableViewDelegate

extension MarketsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketsTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateSlightly()
        tableView.deselectRow(at: indexPath, animated: true)
        let coin = coins[indexPath.row]

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

extension MarketsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        PersistenceManager.shared.favoriteCoinsIDs.swapAt(sourceIndexPath.row, destinationIndexPath.row)
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
}

//MARK: - UISearchBarDelegate

extension MarketsVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        HapticsManager.shared.vibrateSlightly()
        canUpdateSearch = true
        tableView.isHidden = true
        floatingPanel.dismiss(animated: false)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        HapticsManager.shared.vibrateSlightly()
        canUpdateSearch = false
        tableView.isHidden = false
        tableView.reloadData()
        searchResultsVC.floatingPanel.dismiss(animated: false)
    }
}

//MARK: - UISearchResultsUpdating

extension MarketsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchResultsVC.floatingPanel.dismiss(animated: false)
        
        guard let query = searchController.searchBar.text?.lowercased(),
              let searchResultsVC = searchController.searchResultsController as? SearchResultsVC,
              canUpdateSearch else {
            return
        }
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                searchController.searchResultsController?.view.isHidden = false

                searchResultsVC.titleForHeader = "???????????????? ????????????"
                searchResultsVC.update(with: PersistenceManager.shared.latestSearches)
            }
            else if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                searchResultsVC.titleForHeader = nil
                PersistenceManager.shared.searchInCoinsMap(query: query) { coins in
                    searchResultsVC.update(with: coins)
                }
            }
        })
    }
}

//MARK: - FloatingPanelControllerDelegate

extension MarketsVC: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        return location.y > view.height * 0.6 ? true : false
    }
}
