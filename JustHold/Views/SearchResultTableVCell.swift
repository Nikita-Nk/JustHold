import UIKit
import SDWebImage
import SnapKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    
    static let preferredHeight: CGFloat = 65
    
    private var coin = CoinMapData(id: 1, rank: 1, name: "", symbol: "", slug: "", firstHistoricalData: "", lastHistoricalData: "")
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel // .systemGray
        return label
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bitcoinsign.circle")
        imageView.backgroundColor = .white // чтобы png на черном фоне видеть
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 17.5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let toFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()

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
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubviews(logoView, nameLabel, symbolLabel, rankLabel)
        contentView.addSubviews(toFavoriteButton) // чтобы кнопка была кликабельной, добавляем на contentView
        
        toFavoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside) // тут не сработало как в MarketsTableViewCell, поэтому addTarget здесь пишу, а не выше, т.к. в том случае при нажатии ничего не происходит
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
        toFavoriteButton.snp.makeConstraints { make in
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
        toFavoriteButton.imageView?.image = nil
    }
    
    public func configure(with coin: CoinMapData) {
        self.coin = coin
        
        nameLabel.text = self.coin.name
        symbolLabel.text = self.coin.symbol
        rankLabel.text = "\(self.coin.rank)"
        logoView.sd_setImage(with: URL(string: self.coin.logoUrl))
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: self.coin.id))
    }
    
    //MARK: - Private
    
    private func setUpFavoriteButton(inFavorites: Bool) {
        if inFavorites {
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        } else {
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
    }
    
    @objc private func didTapFavoriteButton() {
        HapticsManager.shared.vibrateSlightly()
        
        if PersistenceManager.shared.isInFavorites(coinID: coin.id) {
            PersistenceManager.shared.removeFromFavorites(coinID: coin.id)
            
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
            
            print("Удалили. Количество - \(PersistenceManager.shared.favoriteCoinsIDs.count)")
        } else {
            PersistenceManager.shared.favoriteCoinsIDs.append(coin.id)
            
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
            
            print("Добавили. Количество - \(PersistenceManager.shared.favoriteCoinsIDs.count)")
        }
    }
}