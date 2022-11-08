import UIKit
import RAMAnimatedTabBarController

final class TabBarController: RAMAnimatedTabBarController {
    
    private let selectedColor = UIColor.systemRed
    private let unselectedColor = UIColor.systemMint
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
//        self.setSelectIndex(from: 0, to: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        HapticsManager.shared.vibrateSlightly()
    }
    
    //MARK: - Private

    private func configure() {
        self.tabBar.layer.cornerRadius = 30
        self.tabBar.backgroundColor = .secondarySystemBackground
        
        let vc1 = UINavigationController(rootViewController: MarketsVC())
        let vc2 = UINavigationController(rootViewController: ChartVC())
//        let vc3 = UINavigationController(rootViewController: ViewController())
        let vc4 = UINavigationController(rootViewController: AlertsVC())
        let vc5 = UINavigationController(rootViewController: SettingsVC())
        
        vc1.tabBarItem = RAMAnimatedTabBarItem(title: "Монеты",
                                               image: UIImage(systemName: "star"),
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
        
//        vc3.tabBarItem = RAMAnimatedTabBarItem(title: "Портфолио",
//                                               image: UIImage(systemName: "case"),
//                                               tag: 3,
//                                               animation: RAMFlipLeftTransitionItemAnimations(),
//                                               selectedColor: selectedColor,
//                                               unselectedColor: unselectedColor)

        vc4.tabBarItem = RAMAnimatedTabBarItem(title: "Оповещения",
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
        
        setViewControllers([vc1, vc2, vc4, vc5], animated: false) // vc3,
    }
}

