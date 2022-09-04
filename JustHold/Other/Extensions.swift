import UIKit
import RAMAnimatedTabBarController
import LocalAuthentication

//MARK: - Adds possibility to change tintColor of RAMTabBarItem

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

//MARK: - Change scientific notation to decimal - 1.3204803049961318e-05 to 0.0000132

extension Formatter {
    static let avoidNotation: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
}

extension FloatingPoint {
    var avoidNotation: String {
        return Formatter.avoidNotation.string(for: self) ?? ""
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
            formatter.numberStyle = .decimal // применяю, чтобы запятые(,) были только здесь, в больших числах
            formatter.maximumFractionDigits = 0
        }
        else if self == floor(self) { // если вдруг число целое
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





// Не понадобится?
//MARK: - CandleStick Sorting

extension Array where Element == Candle {
    func getPercentage() -> Double {
        let latestDate = self[0].date // data заменили на self
        guard let latestClose = self.first?.close,
            let priorClose = self.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close
        else {
            return 0
        }
        
//        print("\(symbol): Current \(latestDate): \(latestClose) | Prior: \(priorClose)")
        
        // 267 / 260
        let diff = 1 - priorClose/latestClose
//        print("\(symbol): \(diff)%")
        return diff
    }
}
