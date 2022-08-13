import UIKit

// MARK: - MapResponse
struct MapResponse: Codable {
    let data: [CoinData]
}

// MARK: - CoinData
struct CoinData: Codable, Equatable {
    let id, rank: Int
    let name, symbol, slug: String
    let isActive: Int // 1 if has at least 1 active market. otherwise 0
    let firstHistoricalData, lastHistoricalData: String
    
    let inFavorites = false // на будущее

    enum CodingKeys: String, CodingKey {
        case id, rank, name, symbol, slug
        case isActive = "is_active"
        case firstHistoricalData = "first_historical_data"
        case lastHistoricalData = "last_historical_data"
    }
}
