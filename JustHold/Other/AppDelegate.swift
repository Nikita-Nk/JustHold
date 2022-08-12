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
        
        APICaller.shared.getAllCoins()
        
//        debug()
        
        return true
    }
    
    
    private func debug() {
        
        //
    }
    
}

