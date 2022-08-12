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
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? SearchResultsVC else {
            return
        }
//        print(query)
        
        // Reset timer -  сбрасываем
        searchTimer?.invalidate()
        
        // Kick off new timer - запускаем. Делаем запрос только по прошествии 0.5 секунды
        // Optimize to reduce number of searches
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result) // отправляем результаты поиска в resultsVC // Update SearchResultsVC
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

extension MarketsVC: SearchResultsVCDelegate {
    
    func searchResultsVCdidSelect(searchResult: SearchResult) {
        
        print("did select: \(searchResult.displaySymbol)")
        
        
        // Переход на другую вкладку TBC
        let currentIndex: Int? = self.tabBarController?.selectedIndex
        
        if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController,
           let current = currentIndex {
            ramTBC.setSelectIndex(from: current, to: 1)
        }
    }
}
