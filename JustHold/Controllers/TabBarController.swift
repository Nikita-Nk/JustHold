import UIKit
import RAMAnimatedTabBarController

class TabBarController: RAMAnimatedTabBarController {
    
    private let selectedColor = UIColor.systemRed
    private let unselectedColor = UIColor.systemMint
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        changeRadiusOfTabbar()
        
        self.setSelectIndex(from: 0, to: 2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeHeightOfTabbar()
    }
    
    //MARK: - Private

    private func changeHeightOfTabbar(){
        if UIDevice().userInterfaceIdiom == .phone {
            var tabFrame            = tabBar.frame
            tabFrame.size.height    = 100
            tabFrame.origin.y       = view.frame.size.height - 80
            tabBar.frame            = tabFrame
        }
    }
    
    private func changeRadiusOfTabbar(){
        self.tabBar.layer.masksToBounds = true
        self.tabBar.isTranslucent = true
        self.tabBar.layer.cornerRadius = 30
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func configure() {
        tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: MarketsVC())
        let vc2 = ViewController()
        let vc3 = ViewController()
        let vc4 = ViewController()
        let vc5 = ViewController()
        
        vc2.view.backgroundColor = .systemRed
        vc3.view.backgroundColor = .systemOrange
        vc4.view.backgroundColor = .systemPink
        vc5.view.backgroundColor = .systemMint // 
        
        vc1.tabBarItem = RAMAnimatedTabBarItem(title: "Монеты", // монеты / криптовалюты / главная
                                               image: UIImage(systemName: "star"), // star / house
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

