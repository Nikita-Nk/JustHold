import UIKit

class UIButtonScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Экран скролится, даже если провожу по buttons и textField
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
          return true
        }
        if view.isKind(of: UITextField.self) {
          return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
