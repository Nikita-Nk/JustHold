import UIKit
import SDWebImage
import SnapKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    
    static let preferredHeight: CGFloat = 60
    
    private var coin = CoinData(id: 1, rank: 1, name: "1", symbol: "1", slug: "1", isActive: 1, firstHistoricalData: "1", lastHistoricalData: "1")
    
//    struct CoinModel {
//        let id: Int
//        let name: String
//        let symbol: String
//        let slug: String
//        let logoUrl: String
//        let inFavorites: Bool
//    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bitcoinsign.circle")
        imageView.backgroundColor = .white // чтобы png на черном фоне видеть
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let toFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal) // star.fill / star.slash / star.slash.fill
        button.backgroundColor = .clear
        return button
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubviews(logoView, nameLabel, symbolLabel)
        contentView.addSubviews(toFavoriteButton) // чтобы кнопка была кликабельной, добавляем на contentView
        
        toFavoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = SearchResultTableViewCell.preferredHeight
        let width = contentView.frame.width
        
        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(height/3*2)
            make.centerY.equalTo(contentView.center.y)
            make.leftMargin.equalTo(contentView.left).inset(15)
        }
        nameLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/2)
            make.topMargin.equalTo(contentView.top).inset(15)
            make.leftMargin.equalTo(logoView.snp.right).offset(30)
        }
        symbolLabel.snp.makeConstraints { make in
            make.height.equalTo(height/3)
            make.width.equalTo(width/2)
            make.topMargin.equalTo(nameLabel.snp.bottom).offset(10)
            make.leftMargin.equalTo(logoView.snp.right).offset(30)
        }
        toFavoriteButton.snp.makeConstraints { make in
            make.height.equalTo(height/2)
            make.width.equalTo(height/2)
            make.rightMargin.equalTo(contentView.right).inset(10)
            make.centerY.equalTo(contentView.center.y)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        symbolLabel.text = nil
        logoView.image = nil
        toFavoriteButton.imageView?.image = nil
    }
    
    public func configure(with coin: CoinData) {
        self.coin = coin
        
        nameLabel.text = self.coin.name
        symbolLabel.text = self.coin.symbol
        logoView.sd_setImage(with: URL(string: self.coin.logoUrl))
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coin: self.coin))
    }
    
    //MARK: - Init
    
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
        
        if PersistenceManager.shared.isInFavorites(coin: coin) {
            PersistenceManager.shared.removeFromFavorites(coin: coin)
            
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
            
            print("Удалили. Количество - \(PersistenceManager.shared.favoriteCoins.count)")
        } else {
            PersistenceManager.shared.favoriteCoins.append(coin)
            
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
            
            print("Добавили. Количество - \(PersistenceManager.shared.favoriteCoins.count)")
        }
    }
}
