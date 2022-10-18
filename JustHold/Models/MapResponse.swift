import UIKit

// MARK: - MapResponse
struct MapResponse: Codable {
    let data: [CoinMapData]
    let status: Status
}

// MARK: - CoinData
struct CoinMapData: Codable, Equatable {
    let id, rank: Int
    let name, symbol, slug: String
    let firstHistoricalData: String?
    let lastHistoricalData: String?

    var logoUrl: String {
        "https://s2.coinmarketcap.com/static/img/coins/64x64/\(id).png"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, rank, name, symbol, slug
        case firstHistoricalData = "first_historical_data"
        case lastHistoricalData = "last_historical_data"
    }
}
