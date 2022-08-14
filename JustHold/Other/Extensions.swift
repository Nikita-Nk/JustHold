import UIKit
import RAMAnimatedTabBarController

//MARK: - adds possibility to change tintColor of RAMTabBarItem

extension RAMAnimatedTabBarItem {
    convenience init(title: String, image: UIImage?, tag: Int, animation: RAMItemAnimation, selectedColor: UIColor, unselectedColor: UIColor) {
        self.init(title: title, image: image, tag: 0)
        animation.iconSelectedColor = selectedColor
        animation.textSelectedColor = selectedColor
        self.animation = animation
        self.textColor = unselectedColor
        self.iconColor = unselectedColor
    }
}

//MARK: - Framing

extension UIView {
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}

//MARK: - Add subviews

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
