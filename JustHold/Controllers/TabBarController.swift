import UIKit
import RAMAnimatedTabBarController

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        self.selectedIndex = 2
        
        ChangeRadiusOfTabbar()
    }
    
    func ChangeRadiusOfTabbar(){
        
        self.tabBar.layer.masksToBounds = true
        self.tabBar.isTranslucent = true
        self.tabBar.layer.cornerRadius = 30
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func viewDidLayoutSubviews() {
        ChangeHeightOfTabbar()
    }
    
    func ChangeHeightOfTabbar(){
        
        if UIDevice().userInterfaceIdiom == .phone {
            var tabFrame            = tabBar.frame
            tabFrame.size.height    = 100
            tabFrame.origin.y       = view.frame.size.height - 90
            tabBar.frame            = tabFrame
        }
    }
    
    func configure() {
        
        tabBar.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: ViewController())
        let vc2 = ViewController()
        let vc3 = ViewController()
        let vc4 = ViewController()
        let vc5 = ViewController()
        
        vc1.view.backgroundColor = .systemGreen
        vc2.view.backgroundColor = .systemRed
        vc3.view.backgroundColor = .systemOrange
        vc4.view.backgroundColor = .systemPink
        vc5.view.backgroundColor = .systemMint
        
        vc1.title = "Монеты"
        vc2.title = "График"
        vc3.title = "Портфолио"
        vc4.title = "Сигналы"
        vc5.title = "Настройки"
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: false)
        
        guard let items = self.tabBar.items else {
            return
        }
        
        let images = ["house", "chart.line.uptrend.xyaxis", "case", "bell", "gear"]
        
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
    }
}




class TabBarController: RAMAnimatedTabBarController {
    
    let selectedColor = UIColor.systemRed
    let unselectedColor = UIColor.systemMint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        
        self.setSelectIndex(from: 0, to: 2)
    }
    
    func configure() {
        
        tabBar.isTranslucent = false
        
        let vc1 = UINavigationController(rootViewController: ViewController())
        let vc2 = ViewController()
        let vc3 = ViewController()
        let vc4 = ViewController()
        let vc5 = ViewController()
        
        vc1.view.backgroundColor = .systemGreen
        vc2.view.backgroundColor = .systemRed
        vc3.view.backgroundColor = .systemOrange
        vc4.view.backgroundColor = .systemPink
        vc5.view.backgroundColor = .systemMint
        
        vc1.tabBarItem = RAMAnimatedTabBarItem(title: "Монеты",
                                               image: UIImage(systemName: "house"),
                                               tag: 1,
                                               animation: RAMBounceAnimation(),
                                               selectedColor: selectedColor,
                                               unselectedColor: unselectedColor)
        
        vc2.tabBarItem = RAMAnimatedTabBarItem(title: "График",
                                               image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
                                               tag: 2,
                                               animation: RAMFlipLeftTransitionItemAnimations(),
                                               selectedColor: selectedColor,
                                               unselectedColor: unselectedColor)
        
        vc3.tabBarItem = RAMAnimatedTabBarItem(title: "Портфолио",
                                               image: UIImage(systemName: "case"),
                                               tag: 3,
                                               animation: RAMFlipLeftTransitionItemAnimations(),
                                               selectedColor: selectedColor,
                                               unselectedColor: unselectedColor)

        vc4.tabBarItem = RAMAnimatedTabBarItem(title: "Сигналы",
                                               image: UIImage(systemName: "bell"),
                                               tag: 4,
                                               animation: RAMBounceAnimation(),
                                               selectedColor: selectedColor,
                                               unselectedColor: unselectedColor)

        vc5.tabBarItem = RAMAnimatedTabBarItem(title: "Настройки",
                                               image: UIImage(systemName: "gear"),
                                               tag: 5,
                                               animation: RAMRotationAnimation(),
                                               selectedColor: selectedColor,
                                               unselectedColor: unselectedColor)
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: false)
    }
}

