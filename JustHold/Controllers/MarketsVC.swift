import UIKit
import RAMAnimatedTabBarController

class MarketsVC: UIViewController {
    
    private var searchTimer: Timer?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        setUpTitleView()
        
        view.backgroundColor = .systemGreen
    }
    
    //MARK: - Private
    
    private func setUpTitleView() {
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
        let resultVC = SearchResultsVC()
        resultVC.delegate = self // получаем данные из SearchResultsVC с помощью delegate. И ниже в extension прописываем функцию из protocol
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension MarketsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(),
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? SearchResultsVC else {
            return
        }
//        print(query)
        
        searchTimer?.invalidate() // сброс таймера. Дальше запускаем снова, чтобы оптимизировать ресурсы и кол-во запросов
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            
            PersistanceManager.shared.isCoinInCoinsMap(query: query) { coins in
                DispatchQueue.main.async {
                    resultsVC.update(with: coins) // отправляем результаты поиска в resultsVC
                }
            }
        })
    }
}

extension MarketsVC: SearchResultsVCDelegate {
    
    func searchResultsVCdidSelect(coin: CoinData) {
        
//        print("did select: \(searchResult)") // .displaySymbol
        
        // Передать данные
        
        // Переход на другую вкладку TBC
        let currentIndex: Int? = self.tabBarController?.selectedIndex
        
        if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController,
           let current = currentIndex {
            ramTBC.setSelectIndex(from: current, to: 1)
        }
    }
}
