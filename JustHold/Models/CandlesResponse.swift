import Foundation

// MARK: - CandlesResponse
struct CandlesData: Codable {
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let open: [Double]
    let volume: [Double]
    let status: String // "ok" or "no_data"
    let timestamps: [TimeInterval] // Int
    
    enum CodingKeys: String, CodingKey {
        case close = "c"
        case high = "h"
        case low = "l"
        case open = "o"
        case volume = "v"
        case status = "s"
        case timestamps = "t"
    }
    
    // Конвертируем CandlesData в array Candle (один день - один candle) для удобства
    var candle: [Candle] {
        var result = [Candle]()
        
        for index in 0..<open.count {
            result.append(
                .init(date: Date(timeIntervalSince1970: timestamps[index]),
                      high: high[index],
                      low: low[index],
                      open: open[index],
                      close: close[index])
            )
        }
        
        let sortedData = result.sorted(by: { $0.date > $1.date })
//        print(sortedData[0])
        return sortedData
    }
}

struct Candle {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}
