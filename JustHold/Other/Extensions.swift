import UIKit
import RAMAnimatedTabBarController
import LocalAuthentication

//MARK: - Notification names

extension Notification.Name {
    static let switchToDark = Notification.Name("switchToDark")
    static let switchToChartVC = Notification.Name("switchToChartVC")
    static let playPortfolioAnimation = Notification.Name("playPortfolioAnimation")
}

//MARK: - RAMTabBarItem init with possibility to specify color

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

//MARK: - Prepare value and return string

extension Double {
    
    var preparePercentChange: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    var prepareValue: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if self >= 100000 {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
        }
        else if self == floor(self) {
        }
        else if self < 0.10 && self > -0.10 {
            let coinPrice: Decimal = Decimal(self)
            let leftAndRight = "\(coinPrice)".components(separatedBy: ".")
            
            for (index, char) in leftAndRight[1].enumerated() {
                if char != "0" {
                    formatter.maximumFractionDigits = index + 3
                    return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
                }
            }
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

//MARK: - Date

extension Date {
    
    // Compute the difference between two dates
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func toString(dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

//MARK: - UIDatePicker

extension UIDatePicker {
  
  private func traverse(view: UIView) {
    for subview in view.subviews {
      self.traverse(view: subview)
      subview.alpha = 0.02 // Setting alpha to 0 disables userInteraction.
    }
  }
  
  func paintClear() {
    self.traverse(view: self)
  }
}

//MARK: - Check if String is numeric

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        return Set(self).isSubset(of: nums)
    }
}

//MARK: - UITextField

extension UITextField {
    
    func leftIndent(x: CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: x, height: self.frame.height))
        self.leftViewMode = .always
    }
    
    func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.backgroundColor = .secondarySystemBackground
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(resignFirstResponder))
        keyboardToolbar.items = [flexibleSpace, doneButton]
        keyboardToolbar.tintColor = .label
        self.inputAccessoryView = keyboardToolbar
    }
}

//MARK: - UIViewController

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func fixTabBarVisualEffectBackdropView() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        let tabBar = self.navigationController?.tabBarController?.tabBar
        tabBar?.standardAppearance = appearance
        tabBar?.scrollEdgeAppearance = appearance
    }
}

//MARK: - Show alert

extension UIViewController {
    func showAlert(viewModel: PopupAlertViewViewModel) {
        let alert = PopupAlertView()
        alert.configure(with: viewModel)
        self.navigationController?.tabBarController?.tabBar.addSubview(alert)
        alert.frame = CGRect(x: 20, y: 0, width: self.view.width-40, height: 50)
        alert.dropShadow(color: .systemBackground, opacity: 0.5, radius: 10)
        alert.alpha = 1

        UIView.animate(withDuration: 0.2, animations: {
            alert.alpha = 1
            alert.frame.origin.y -= 60
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.2, animations: {
                alert.alpha = 0
                alert.frame.origin.y += 60
            }) { (true) in
                alert.removeFromSuperview()
            }
        }
    }
}

//MARK: - Drop shadow

extension UIView {
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize = CGSize(width: 0, height: 0), radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius
    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
