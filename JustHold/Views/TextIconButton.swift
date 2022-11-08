import UIKit

final class TextIconButton: UIButton {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label.withAlphaComponent(0.9)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(label, iconImageView)
        clipsToBounds = true
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray.withAlphaComponent(0.6).cgColor
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String = "", image: UIImage?) {
        label.text = text
        iconImageView.image = image
    }
    
    public func changeLabel(newText: String) {
        label.text = newText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(15)
            make.centerY.equalTo(snp.centerY)
        }
        iconImageView.snp.makeConstraints { make in
            make.height.width.equalTo(18)
            make.right.equalTo(snp.right).inset(10)
            make.centerY.equalTo(snp.centerY)
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            if isHighlighted || isSelected {
                layer.borderColor = UIColor.systemBlue.cgColor
                layer.borderWidth = 2
            } else {
                layer.borderColor = UIColor.systemGray.withAlphaComponent(0.6).cgColor
                layer.borderWidth = 1
            }
        }
    }
}
