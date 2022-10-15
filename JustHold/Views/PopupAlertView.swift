import UIKit

class PopupAlertView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.textColor = .systemGray6
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(label, iconImageView)
        backgroundColor = .label
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.snp.makeConstraints { make in
            make.height.width.equalTo(height/2)
            make.left.equalTo(snp.left).inset(15)
            make.centerY.equalTo(snp.centerY)
        }
        label.snp.makeConstraints { make in
            if iconImageView.isHidden {
                make.left.equalTo(snp.left).inset(15)
            } else {
                make.left.equalTo(iconImageView.snp.right).offset(10)
            }
            make.right.equalTo(snp.right).inset(15)
            make.centerY.equalTo(iconImageView.snp.centerY)
        }
    }
    
    //MARK: - Public
    
    public func configure(with viewModel: PopupAlertViewViewModel) {
        label.text = viewModel.text
        iconImageView.isHidden = viewModel.imageIsHidden
        iconImageView.tintColor = viewModel.imageViewColor
        iconImageView.image = viewModel.image
    }
    
    //MARK: - Private
    
    // Gesture не работает, т.к. alertView находится за пределами tabBar
    private func setUpSwipeGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
    
    @objc private func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {
        print("swipeDown")
    }
}
