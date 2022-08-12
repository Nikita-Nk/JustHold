import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = TabBarController()
        
        
//        debug()
        
        return true
    }
    
    
    private func debug() {
        
        APICaller.shared.search(query: "Apple") { result in
            switch result {
            case .success(let response):
                print(response.result)
            case .failure(let error):
                print(error)
            }
        }
        // Результат - https://finnhub.io/api/v1/search?q=Apple&token=cb5rid2ad3i0dk7b9ca0
    }
    
}

