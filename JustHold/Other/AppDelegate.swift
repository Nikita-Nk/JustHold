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
        checkColorMode()
        NotificationCenter.default.addObserver(self, selector: #selector(switchToDark), name: Notification.Name("switchToDark"), object: nil)
        
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
    
    //MARK: - Check and change interface style
    
    private func checkColorMode() {
        switch PersistenceManager.shared.darkModeIsOn {
        case true:
            window?.overrideUserInterfaceStyle = .dark
        case false:
            window?.overrideUserInterfaceStyle = .light
        }
    }
    
    @objc func switchToDark(_ notification: Notification) {
        switch PersistenceManager.shared.darkModeIsOn {
        case true:
            window?.overrideUserInterfaceStyle = .light
            PersistenceManager.shared.darkModeIsOn = false
        case false:
            window?.overrideUserInterfaceStyle = .dark
            PersistenceManager.shared.darkModeIsOn = true
        }
    }
}

