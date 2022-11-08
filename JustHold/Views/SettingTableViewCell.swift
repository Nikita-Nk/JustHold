import UIKit

final class SettingTableViewCell: UITableViewCell {

    static let identifier = "SettingTableViewCell"
    
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
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(iconContainer, label)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator // добавляет справа стрелочку (указывает на переход куда-то)
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
        label.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.centerY.equalTo(contentView.center.y)
            make.leftMargin.equalTo(iconContainer.snp.right).offset(15)
            make.rightMargin.equalTo(contentView.snp.right).inset(25)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    public func configure(with model: SettingsOption) {
        label.text = model.text
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
    }
}
