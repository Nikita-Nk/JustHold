import UIKit

struct PopupAlertViewViewModel {
    
    let text: String
    var imageViewColor: UIColor?
    var image: UIImage?
    var imageIsHidden: Bool = false
    
    init(result: OperationResult, text: String) {
        self.text = text
        
        switch result {
        case .success:
            imageViewColor = .systemGreen
            image = UIImage(systemName: "checkmark.circle")
            HapticsManager.shared.vibrate(for: .success)
        case.failure:
            imageViewColor = .systemRed
            image = UIImage(systemName: "xmark.shield")
            HapticsManager.shared.vibrate(for: .error)
        case .onlyText:
            imageIsHidden = true
            HapticsManager.shared.vibrateSlightly()
        }
    }
}

// MARK: - Nested Types

extension PopupAlertViewViewModel {
    
    enum OperationResult {
        case success
        case failure
        case onlyText
    }
}
