import UIKit

// MARK: - QuotesResponse
struct QuotesResponse: Codable {
    let data: [String: CoinListingData]
    let status: Status
}
