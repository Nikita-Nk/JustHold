import UIKit
import Charts

struct ChartViewViewModel {
    
    var dates = [String]()
    var entries = [CandleChartDataEntry]()
    
    init(candles: [Candle]) {
        for (index, value) in candles.enumerated() {
            entries.append(.init(x: Double(index),
                                 shadowH: value.high,
                                 shadowL: value.low,
                                 open: value.open,
                                 close: value.close,
                                 data: ""))
        }
        
        let delta = candles[1].date - candles[0].date // 86400с для "D" таймфрейма
        dates = candles.map { $0.date.toString(dateFormat: "dd MMM") }
        let lastCandleIndex = candles.count - 1
        var lastDate = candles[lastCandleIndex].date
        
        var candlesCountToAdd = Int(Double(candles.count) * 0.2) // Если вдруг общее число свечей меньше 5, то добавим хотя бы 1 пустую свечу
        if candlesCountToAdd < 1 {
            candlesCountToAdd = 1
        }
        
        for i in 1...candlesCountToAdd {
            // Добавляю 20% пустых entries, чтобы при долистывании графика до правого угла, была свободная зона и не видно было пропажи графика
            entries.append(.init(x: Double(i + lastCandleIndex),
                                 shadowH: candles[lastCandleIndex].close,
                                 shadowL: candles[lastCandleIndex].close,
                                 open: candles[lastCandleIndex].close,
                                 close: candles[lastCandleIndex].close))
            
            // Добавляю даты для пустых значений
            lastDate = lastDate.addingTimeInterval(delta)
            dates.append(lastDate.toString(dateFormat: "dd MMM"))
        }
    }
}
