import UIKit

final class HapticsManager {
    
    static let shared = HapticsManager()
    
    private init() {}
    
    //MARK: - Public
    
    public func vibrateSlightly() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
