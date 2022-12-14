import Foundation

// MARK: - CandlesResponse
struct CandlesData: Codable {
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let open: [Double]
    let volume: [Double]
    let status: String
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case close = "c"
        case high = "h"
        case low = "l"
        case open = "o"
        case volume = "v"
        case status = "s"
        case timestamps = "t"
    }
    
    var candles: [Candle] {
        var result = [Candle]()
        
        for index in 0..<open.count {
            result.append(
                .init(date: Date(timeIntervalSince1970: timestamps[index]),
                      high: high[index],
                      low: low[index],
                      open: open[index],
                      close: close[index],
                      volume: volume[index])
            )
        }
        
        let sortedData = result.sorted(by: { $0.date > $1.date })
        return sortedData
    }
}
