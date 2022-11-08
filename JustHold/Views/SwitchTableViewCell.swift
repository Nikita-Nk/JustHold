import UIKit

final class SwitchTableViewCell: UITableViewCell {
    
    static let identifier = "SwitchTableViewCell"
    
    private var model: SettingsSwitchOption!
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let switchToDark: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = .systemGreen
        mySwitch.addTarget(self, action: #selector(didTapSwitch), for: .valueChanged)
        return mySwitch
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(iconContainer, label, switchToDark)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.centerY.equalTo(contentView.snp.centerY)
            make.leftMargin.equalTo(contentView.left).inset(10)
        }
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.center.equalTo(iconContainer.snp.center)
        }
        switchToDark.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.rightMargin.equalTo(contentView.right).inset(10)
        }
        label.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.centerY.equalTo(contentView.center.y)
            make.leftMargin.equalTo(iconContainer.snp.right).offset(15)
            make.rightMargin.equalTo(switchToDark.snp.left).offset(-10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        switchToDark.isOn = false
    }
    
    public func configure(with model: SettingsSwitchOption) {
        self.model = model
        
        label.text = model.text
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        switchToDark.isOn = model.isOn
    }
    
    //MARK: - Private
    
    @objc private func didTapSwitch() {
        model.handler()
    }
}
