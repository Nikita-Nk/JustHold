import UIKit
import SDWebImage
import SnapKit

class MarketsTableViewCell: UITableViewCell {
    
    static let identifier = "MarketsTableViewCell"
    
    static let preferredHeight: CGFloat = 65
    
    private var coin = CoinListingData(id: 1, name: "", symbol: "", slug: "", rank: 1, circulatingSupply: 1, totalSupply: 1, maxSupply: 1, lastUpdated: "", dateAdded: "", quote: ["": Quote(price: 1, volume24H: 1, volumeChange24H: 1, percentChange1H: 1, percentChange24H: 1, percentChange7D: 1, marketCap: 1, marketCapDominance: 1, fullyDilutedMarketCap: 1, lastUpdated: "")])
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bitcoinsign.circle")
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 17.5
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let toFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapFavoriteButton(_:)), for: .touchUpInside) // (_:) - чтобы не было ошибки. ! Но если написать MarketsTableViewCell.self, как в warning, то будет ошибка
        return button
    }()
    
    private class RankLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 6
            return CGSize(width: originalContentSize.width + 14, height: height)
        }
    }

    private let rankLabel: RankLabel = {
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
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let percentChangeLabel: UILabel = {
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
        contentView.addSubviews(toFavoriteButton) // чтобы кнопка была кликабельной, добавляем на contentView
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
        
        nameLabel.text = self.coin.name
        symbolLabel.text = self.coin.symbol
        rankLabel.text = "\(self.coin.rank)"
        logoView.sd_setImage(with: URL(string: self.coin.logoUrl))
        setUpPriceLabel()
        setUpChangeLabel()
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: self.coin.id))
    }
    
    //MARK: - Private
    
    private func setUpPriceLabel() {
        let coinPrice = self.coin.quote["USD"]?.price ?? 0
        let leftAndRight = "\(coinPrice)".components(separatedBy: ".")
        
        if coinPrice > 0.98 {
            priceLabel.text = leftAndRight[0] + "." + leftAndRight[1].prefix(2)
        }
        else if coinPrice <= 0.98 {
            for (index, char) in leftAndRight[1].enumerated() {
                if char != "0" {
                    priceLabel.text = leftAndRight[0] + "." + leftAndRight[1].prefix(index + 3)
                    break
                }
            }
        }
    }
    
    private func setUpChangeLabel() {
        if let percentChange = coin.quote["USD"]?.percentChange24H {
            if percentChange >= 0 {
                percentChangeLabel.textColor = .systemGreen
                percentChangeLabel.text = "+\(percentChange)".prefix(5) + "%"
            } else {
                percentChangeLabel.textColor = .red
                percentChangeLabel.text = "\(percentChange)".prefix(5) + "%"
            }
        }
    }
    
    private func setUpFavoriteButton(inFavorites: Bool) {
        if inFavorites {
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        } else {
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
    }
    
    @objc private func didTapFavoriteButton(_: UIButton) {
        
        if PersistenceManager.shared.isInFavorites(coinID: coin.id) {
            PersistenceManager.shared.removeFromFavorites(coinID: coin.id)
            
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
            
            print("Удалили. Количество - \(PersistenceManager.shared.favoriteCoins.count)")
        }
        else {
            PersistenceManager.shared.favoriteCoins.append(coin.id)
            
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
            
            print("Добавили. Количество - \(PersistenceManager.shared.favoriteCoins.count)")
        }
    }
}
