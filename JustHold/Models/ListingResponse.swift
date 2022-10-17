import UIKit

// MARK: - ListingResponse
struct ListingResponse: Codable {
    let data: [CoinListingData]
    let status: Status
}

// MARK: - CoinListingData
// data["1"]?.quote["USD"]?.price ?? 0 // Пример доступа
struct CoinListingData: Codable {
    let id: Int
    let name, symbol, slug: String
    let rank: Int // cmcRank
    let circulatingSupply, totalSupply, maxSupply: Double?
    let lastUpdated, dateAdded: String?
    let quote: [String: Quote]
    
    lazy var logoUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/\(id).png"

    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug
        case rank = "cmc_rank"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case lastUpdated = "last_updated"
        case dateAdded = "date_added"
        case quote
    }
}

// MARK: - Quote
struct Quote: Codable {
    let price: Double
    let volume24H: Double
    let volumeChange24H, percentChange1H, percentChange24H, percentChange7D: Double
    let marketCap: Double
    let marketCapDominance: Double
    let fullyDilutedMarketCap: Double
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case price
        case volume24H = "volume_24h"
        case volumeChange24H = "volume_change_24h"
        case percentChange1H = "percent_change_1h"
        case percentChange24H = "percent_change_24h"
        case percentChange7D = "percent_change_7d"
        case marketCap = "market_cap"
        case marketCapDominance = "market_cap_dominance"
        case fullyDilutedMarketCap = "fully_diluted_market_cap"
        case lastUpdated = "last_updated"
    }
}

// MARK: - Status
struct Status: Codable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}
