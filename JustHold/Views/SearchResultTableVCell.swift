import UIKit
import SDWebImage
import SnapKit

final class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    
    static let preferredHeight: CGFloat = 65
    
    private var coin: CoinMapData?
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bitcoinsign.circle")
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 17.5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var addToFavoritesButton = AddToFavoritesButton()

    private lazy var rankLabel: RankLabel = {
        let label = RankLabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.text = ""
        label.frame.size = label.intrinsicContentSize
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .systemGray6
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubviews(logoView, nameLabel, symbolLabel, rankLabel)
        contentView.addSubview(addToFavoritesButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = SearchResultTableViewCell.preferredHeight
        let width = contentView.width
        
        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalTo(contentView.center.y)
            make.leftMargin.equalTo(contentView.left).inset(10)
        }
        nameLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/2)
            make.topMargin.equalTo(contentView.top).inset(15)
            make.leftMargin.equalTo(logoView.snp.right).offset(20)
        }
        rankLabel.snp.makeConstraints { make in
            make.bottomMargin.equalTo(contentView.bottom).inset(15)
            make.leftMargin.equalTo(nameLabel.snp.leftMargin)
        }
        symbolLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/2)
            make.centerY.equalTo(rankLabel.snp.centerY)
            make.leftMargin.equalTo(rankLabel.snp.right).offset(15)
        }
        addToFavoritesButton.snp.makeConstraints { make in
            make.height.width.equalTo(height/2)
            make.rightMargin.equalTo(contentView.right).inset(10)
            make.centerY.equalTo(contentView.center.y)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        symbolLabel.text = nil
        rankLabel.text = nil
        logoView.image = nil
    }
    
    // MARK: - Public
    
    public func configure(with coin: CoinMapData) {
        self.coin = coin
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        rankLabel.text = "\(coin.rank)"
        logoView.sd_setImage(with: URL(string: coin.logoUrl))
        addToFavoritesButton.configure(coinID: coin.id, forChart: false)
    }
}
