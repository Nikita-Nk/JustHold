import UIKit

final class AddToFavoritesButton: UIButton {
    
    private var coinID = Int()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(systemName: "star"), for: .normal)
        backgroundColor = .clear
        addTarget(self, action: #selector(didTapAddToFavoritesButton(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func configure(coinID: Int, forChart: Bool) {
        self.coinID = coinID
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: coinID))
        guard forChart else { return }
        self.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
    }
}

// MARK: - Private

private extension AddToFavoritesButton {
    
    @objc func didTapAddToFavoritesButton(_: UIButton) {
        if PersistenceManager.shared.isInFavorites(coinID: coinID) {
            PersistenceManager.shared.removeFromFavorites(coinID: coinID)
        } else {
            PersistenceManager.shared.favoriteCoinsIDs.append(coinID)
        }
        
        setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: coinID))
        HapticsManager.shared.vibrateSlightly()
    }
    
    func setUpFavoriteButton(inFavorites: Bool) {
        if inFavorites {
            self.setImage(UIImage(systemName: "star.fill"), for: .normal)
            self.tintColor = .systemYellow
        } else {
            self.setImage(UIImage(systemName: "star"), for: .normal)
            self.tintColor = .systemGray
        }
    }
}
