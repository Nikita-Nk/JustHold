import UIKit

import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = TabBarController()
        
        
        // if первый раз в приложении - в PersistenceM создать константу, которая берет значение из UserDefaults
        if UserDefaults.standard.data(forKey: "favoriteCoins") != nil {
            print("!!!")
        } else {
            print("nil nil nil")
            PersistanceManager.shared.favoriteCoins = [CoinData]() // без этого зависание в момент обращения к этому массиву
        }
        

        APICaller.shared.getAllCoins()
        
//        debug()
        
        return true
    }
    
    
    private func debug() {
        
    }
    
}

