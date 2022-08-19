import UIKit

// MARK: - QuotesResponse
struct QuotesResponse: Codable {
    let data: [String: CoinListingData] // [CoinQuoteData]
    let status: Status
}

// MARK: - Datum
// data["1"]?.quote.usd.price // Пример доступа, если выбрать CoinQuoteData, здесь quote по-другому записан
//struct CoinQuoteData: Codable {
//    let id: Int
//    let name, symbol, slug: String
//    let isActive, isFiat: Int
//    let circulatingSupply, totalSupply: Double
//    let maxSupply: Int?
//    let dateAdded: String
//    let rank: Int
//    let lastUpdated: String
//    let quote: Quote1
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, symbol, slug
//        case isActive = "is_active"
//        case isFiat = "is_fiat"
//        case circulatingSupply = "circulating_supply"
//        case totalSupply = "total_supply"
//        case maxSupply = "max_supply"
//        case dateAdded = "date_added"
//        case rank = "cmc_rank"
//        case lastUpdated = "last_updated"
//        case quote
//    }
//}
//
//// MARK: - Quote
//struct Quote1: Codable {
//    let usd: Usd
//
//    enum CodingKeys: String, CodingKey {
//        case usd = "USD"
//    }
//}
//
//// MARK: - Usd
//struct Usd: Codable {
//    let price, volume24H, volumeChange24H, percentChange1H: Double
//    let percentChange24H, percentChange7D, percentChange30D, marketCap: Double
//    let marketCapDominance: Double
//    let fullyDilutedMarketCap: Double
//    let lastUpdated: String
//
//    enum CodingKeys: String, CodingKey {
//        case price
//        case volume24H = "volume_24h"
//        case volumeChange24H = "volume_change_24h"
//        case percentChange1H = "percent_change_1h"
//        case percentChange24H = "percent_change_24h"
//        case percentChange7D = "percent_change_7d"
//        case percentChange30D = "percent_change_30d"
//        case marketCap = "market_cap"
//        case marketCapDominance = "market_cap_dominance"
//        case fullyDilutedMarketCap = "fully_diluted_market_cap"
//        case lastUpdated = "last_updated"
//    }
//}
