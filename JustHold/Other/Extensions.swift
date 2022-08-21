import UIKit
import RAMAnimatedTabBarController
import LocalAuthentication

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

//MARK: - LocalAuthentication

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                print("Handle new Biometric type")
            }
        }
        
        return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}
