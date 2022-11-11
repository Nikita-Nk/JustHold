import UIKit
import SkeletonView

final class MetricCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MetricCollViewCell"
    
    private let fontSize: CGFloat = 12
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: fontSize)
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: fontSize)
        return label
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel, valueLabel)
        self.isSkeletonable = true
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
    
    public func configure(with viewModel: MetricCollectionViewCellViewModel) {
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
        valueLabel.textColor = viewModel.valueColor
        
        valueLabel.alpha = 0.7
        UIView.animate(withDuration: 0.9) {
            self.valueLabel.alpha = 1
        }
    }
}
