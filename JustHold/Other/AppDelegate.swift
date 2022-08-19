import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = TabBarController()
        
        APICaller.shared.fetchAllCoins()
        
//        debug()
        
        return true
    }
    
    private func debug() {
        
        // Для проверки
//        AF.request("https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest",
//                   method: .get,
//                   parameters: ["id": "1,2,3"],
//                   headers: APICaller.Constants.headers).responseJSON { response in
//            print(response)
//        }
    }
}

