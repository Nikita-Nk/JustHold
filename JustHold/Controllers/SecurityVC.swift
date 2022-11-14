import UIKit
import LocalAuthentication
import SnapKit
import Lottie

final class SecurityVC: UIViewController {
    
    private lazy var authButton: UIButton = {
        let button = UIButton()
        button.setTitle("Повторить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.imageView?.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "lock.open"), for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        return button
    }()
    
    private lazy var animationView: AnimationView = {
        let animation = AnimationView()
        animation.animation = Animation.named("chartAnimation")
        animation.backgroundColor = .systemBackground
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1.1
        animation.play()
        return animation
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubviews(animationView, authButton)
        authenticate()
    }
    
    override func viewDidLayoutSubviews() {
        animationView.snp.makeConstraints { make in
            make.leftMargin.equalTo(view.snp.leftMargin).offset(-9)
            make.rightMargin.equalTo(view.snp.rightMargin)
            make.centerY.equalTo(view.snp.centerY).offset(-150)
        }
        authButton.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(50)
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(200)
        }
    }
}

// MARK: - Private

private extension SecurityVC {
    
    @objc func authenticate() {
        HapticsManager.shared.vibrateSlightly()
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reasonTouchID = "Авторизируйтесь с помощью Touch ID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reasonTouchID) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else {
                        // ошибка
                        let alert = UIAlertController(title: "Ошибка аутентификации", message: "Пожалуйста, попробуйте снова", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                        self?.present(alert, animated: true)
                        return
                    }
                    // успех
                    let vc = TabBarController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self?.present(nav, animated: true, completion: nil)
                }
            }
        }
        else {
            // если пользователь не дал разрешение на использование функции
            let alert = UIAlertController(title: "Недоступно", message: "Вы не можете использовать эту функцию. Включите FaceID в настройках приложения JustHold", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
