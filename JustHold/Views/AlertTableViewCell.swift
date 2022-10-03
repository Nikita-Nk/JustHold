import UIKit
import RealmSwift

protocol AlertTableViewCellDelegate: AnyObject {
    func showErrorAlert()
}

class AlertTableViewCell: UITableViewCell {
    
    weak var delegate: AlertTableViewCellDelegate?
    
    static let identifier = "AlertsTableViewCell"
    
    private var alert: AlertModel!
    
    private let bellView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bell.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let switchControl: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = .systemBlue
        mySwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        mySwitch.addTarget(self, action: #selector(didTapSwitch), for: .valueChanged)
        return mySwitch
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(bellView, nameLabel, expirationLabel, switchControl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.centerY).offset(-2)
            make.left.equalTo(contentView.snp.left).offset(20)
            make.right.equalTo(bellView.snp.left).offset(-5)
        }
        expirationLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.centerY).offset(3)
            make.horizontalEdges.equalTo(nameLabel.snp.horizontalEdges)
        }
        switchControl.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.centerY.equalTo(contentView.snp.centerY)
            make.right.equalTo(contentView.snp.right).inset(20)
        }
        bellView.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.centerY.equalTo(contentView.snp.centerY)
            make.right.equalTo(switchControl.snp.left).inset(-10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        expirationLabel.text = nil
    }
    
    public func configure(with alert: AlertModel) {
        self.alert = alert
        
        print(alert.expirationDateDisabled)
        var expireText = ""
        if alert.expirationDateDisabled {
            expireText = "Без срока истечения"
        } else {
            expireText = "Истекает " + alert.expirationDate.toString(dateFormat: "dd MMM HH:mm")
        }
        expirationLabel.text = alert.coinName + "  •  " + expireText
        
        if !alert.expirationDateDisabled && alert.expirationDate < Date() {
            switchControl.isOn = false
            try! Realm().write {
                alert.isAlertActive = false
            }
        } else {
            switchControl.isOn = alert.isAlertActive ? true : false
        }
        
        bellView.isHidden = !alert.didConditionMatchAfterLastCheck
        nameLabel.text = alert.alertName
    }
    
    //MARK: - Private
    
    @objc private func didTapSwitch() {
        if alert.expirationDateDisabled == false && alert.expirationDate < Date() {
            delegate?.showErrorAlert()
            switchControl.isOn = false
        }
        try! Realm().write {
            alert.isAlertActive.toggle()
        }
    }
}
