import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MetricCollViewCell"
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left)
            make.top.equalTo(contentView.snp.top)
        }
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.bottom.equalTo(nameLabel.snp.bottom)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(with viewModel: ViewModel, color: UIColor) {
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
        valueLabel.textColor = color
    }
}
