import UIKit

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
            print("not nil")
        } else {
            print("nil nil nil")
            PersistenceManager.shared.favoriteCoins = [CoinData]() // без этого зависание в момент обращения к этому массиву. Т.к. надо сначала хоть что-то проинициализировать?
        }
        
        // Теперь ошибки нет, даже если нет значений
        if PersistenceManager.shared.favoriteCoins.isEmpty {
            print("Пусто")
        }

        APICaller.shared.getAllCoins()
        
//        debug()
        
        return true
    }
    
//    private func checkIfFirstTime() {
//
//    }
    
//    private func debug() {
//
//    }
}

