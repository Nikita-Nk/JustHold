import UIKit
import SDWebImage
import RAMAnimatedTabBarController

class MarketsVC: UIViewController {
    
    private var searchTimer: Timer?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupSearchController()
        setUpNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
    }
    
    //MARK: - Private
    
    @objc private func favoritesTapped() {
        print(PersistenceManager.shared.favoriteCoins)
    }
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"), // star.fill / star.slash / star.slash.fill
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(favoritesTapped))
        
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
        let searchVC = UISearchController(searchResultsController: searchResultsVC)
        searchVC.searchBar.placeholder = "Искать монеты..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension MarketsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(),
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let searchResultsVC = searchController.searchResultsController as? SearchResultsVC else {
            return
        }
        
        searchTimer?.invalidate() // сброс таймера. Дальше запускаем снова, чтобы оптимизировать ресурсы и кол-во запросов
        // На самом деле сейчас не нужно, т.к. для поиска не делаем запрос, а ищем по загруженному списку
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            
            PersistenceManager.shared.searchInCoinsMap(query: query) { coins in
                searchResultsVC.update(with: coins) // отправляем результаты поиска в searchResultsVC
            }
        })
    }
}

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
