import UIKit

final class HapticsManager {
    
    static let shared = HapticsManager()
    
    private init() {}
    
    //MARK: - Public
    
    // Легкая вибрация
    public func vibrateSlightly() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // 3 типа вибрации (более сильные): success, warning, error
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
