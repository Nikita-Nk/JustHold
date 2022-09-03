import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = PersistenceManager.shared.securityIsOn ? SecurityVC() : TabBarController()
        
        APICaller.shared.fetchCoinsMap()
        APICaller.shared.fetchAllSymbols()
        checkColorMode()
        NotificationCenter.default.addObserver(self, selector: #selector(switchToDark), name: Notification.Name("switchToDark"), object: nil)
        
//        debug()
        print(1.0.prepareValue)
        print(0.prepareValue)
        print(0.0000007125358.prepareValue)
        print(123.2897345273438275723.prepareValue)
        print(2139742.1481.prepareValue)
        
        return true
    }
    
    private func debug() {
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
    
    @objc private func switchToDark(_ notification: Notification) {
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

