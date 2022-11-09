import UIKit
import Lottie

final class SettingsTableFooterView: UITableViewHeaderFooterView {
    
    static let identifier = "SettingsTableFooterView"
    
    private let animationView: AnimationView = {
        let animation = AnimationView()
        animation.animation = Animation.named("portfolioAnimation")
        animation.backgroundColor = .clear
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1.1
        animation.play()
        return animation
    }()
    
    //MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(animationView)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification), name: .playPortfolioAnimation, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationView.frame = CGRect(x: 0, y: 5, width: contentView.width, height: contentView.height - 5)
    }
    
    //MARK: - Private
    
    @objc private func didGetNotification(_ notification: Notification) {
        animationView.play()
    }
}
