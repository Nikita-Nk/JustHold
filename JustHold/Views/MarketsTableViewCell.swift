import UIKit
import SDWebImage
import SnapKit

final class MarketsTableViewCell: UITableViewCell {
    
    static let identifier = "MarketsTableViewCell"
    
    static let preferredHeight: CGFloat = 65
    
    private var coin: CoinListingData?
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
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
    
    private lazy var toFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapFavoriteButton(_:)), for: .touchUpInside)
        return button
    }()

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
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private lazy var percentChangeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubviews(logoView, nameLabel, symbolLabel, rankLabel, priceLabel, percentChangeLabel)
        contentView.addSubviews(toFavoriteButton)
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
            make.width.equalTo(width/3)
            make.centerY.equalTo(rankLabel.snp.centerY)
            make.leftMargin.equalTo(rankLabel.snp.right).offset(15)
        }
        
        toFavoriteButton.snp.makeConstraints { make in
            make.height.width.equalTo(height/2)
            make.rightMargin.equalTo(contentView.right).inset(10)
            make.centerY.equalTo(contentView.center.y)
        }
        priceLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/3)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.rightMargin.equalTo(toFavoriteButton.snp.left).offset(-15)
        }
        percentChangeLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/3)
            make.centerY.equalTo(symbolLabel.snp.centerY)
            make.rightMargin.equalTo(priceLabel.snp.rightMargin)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        symbolLabel.text = nil
        rankLabel.text = nil
        logoView.image = nil
        priceLabel.text = nil
        percentChangeLabel.text = nil
        toFavoriteButton.imageView?.image = nil
    }
    
    public func configure(with coin: CoinListingData) {
        self.coin = coin
        
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        rankLabel.text = "\(coin.rank)"
        logoView.sd_setImage(with: URL(string: coin.logoUrl))
        setUpPriceLabel()
        setUpChangeLabel()
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: coin.id))
    }
}

// MARK: - Private

private extension MarketsTableViewCell {
    
    func setUpPriceLabel() {
        let price = coin?.quote["USD"]?.price ?? 0
        priceLabel.text = price.prepareValue
    }
    
    func setUpChangeLabel() {
        if let percentChange = coin?.quote["USD"]?.percentChange24H {
            if percentChange >= 0 {
                percentChangeLabel.textColor = .systemGreen
                percentChangeLabel.text = "+" + percentChange.preparePercentChange + "%"
            } else {
                percentChangeLabel.textColor = .red
                percentChangeLabel.text = percentChange.preparePercentChange + "%"
            }
        }
    }
    
    func setUpFavoriteButton(inFavorites: Bool) {
        if inFavorites {
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        } else {
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
    }
    
    @objc func didTapFavoriteButton(_: UIButton) {
        HapticsManager.shared.vibrateSlightly()
        guard let coin = coin else { return }
        
        if PersistenceManager.shared.isInFavorites(coinID: coin.id) {
            PersistenceManager.shared.removeFromFavorites(coinID: coin.id)
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
        else {
            PersistenceManager.shared.favoriteCoinsIDs.append(coin.id)
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        }
    }
}
