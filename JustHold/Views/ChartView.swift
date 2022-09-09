import UIKit
import Charts

// Передавать сюда из ChartVC ещё выбранный таймфрейм и на основе него настраивать dateFormat

//MARK: - MyChartViewDelegate

protocol MyChartViewDelegate: AnyObject {
    func chartValueSelected(index: Int)
}

//MARK: - ChartView

class ChartView: UIView {
    
    weak var delegate: MyChartViewDelegate?
    
    private let chartView: CandleStickChartView = {
        let chart = CandleStickChartView()
        chart.backgroundColor = .systemBackground
        chart.xAxis.axisLineColor = .systemBackground // цвет нижней линии сетки
        chart.rightAxis.axisLineColor = .systemBackground  // цвет правой линии сетки
        chart.rightAxis.gridColor = .systemGray4 // меняю цвета линий у сетки
        chart.xAxis.gridColor = .systemGray4
        chart.legend.enabled = false // убираю расшифровку снизу (не сами значения)
        chart.minOffset = 0 // отступ слева
        
        chart.xAxis.granularity = 3.0 // интервал между значениями при максимальном приближении. В каждой клетке будет 3 свечи
        chart.xAxis.labelPosition = .bottom // xAxis значения только снизу
        chart.xAxis.labelFont = .systemFont(ofSize: 12, weight: .bold)
        chart.xAxis.setLabelCount(4, force: false)
//        chart.xAxis.labelTextColor = .white
        
        chart.leftAxis.enabled = false // отключаю значения слева и включаю справа
        chart.rightAxis.enabled = true
        chart.rightAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        chart.rightAxis.setLabelCount(12, force: false) // количество лейблов справа
        chart.rightAxis.labelPosition = .outsideChart
        
        chart.doubleTapToZoomEnabled = false
//        chart.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        // На долгое нажатие включать перекрестие и чтобы его можно было двигать как угодно (справа цена, а снизу дата)
        
        chart.zoom(scaleX: 1.01, scaleY: 0, x: 0, y: 0) // минимальный зум, чтобы свечи сразу отображались, т.к. без этого график пустой
//        chart.zoom(scaleX: 20, scaleY: 20, x: 20, y: 200) // Как зумить именно конец графика? Через chart.chartXMax ?
        
        // https://stackoverflow.com/questions/52369453/ios-charts-zoom-into-a-range-of-values - не работает
//        chart.setVisibleXRange(minXRange: <#T##Double#>, maxXRange: <#T##Double#>)
        
        chart.drawMarkers = true
//        chart.marker // добавлять созданный маркер
        
        return chart
        
        // Вроде не нужно
//        chart.notifyDataSetChanged()
//        chart.animate(xAxisDuration: 5.0) // красиво, но не особо подходит для candleChart
        
//        chart.drawBordersEnabled = true
//        chart.borderColor = .red // линия по всем краям графика
//        chart.borderLineWidth
        
//        chart.pinchZoomEnabled = false // вроде разницы нет
//        chart.setScaleEnabled(true)
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
        backgroundColor = .systemBackground
        chartView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    func reset() {
        chartView.data = nil
    }
    
    func configure(with candles: [Candle]) {
        var entries = [CandleChartDataEntry]()
        
        for (index, value) in candles.enumerated() {
            entries.append(.init(x: Double(index),
                                 shadowH: value.high,
                                 shadowL: value.low,
                                 open: value.open,
                                 close: value.close,
                                 data: ""))
        }
        
        let delta = candles[1].date - candles[0].date // 86400с для "D" таймфрейма
        var dates = candles.map { $0.date.toString(dateFormat: "dd MMM") }
        let lastCandleIndex = candles.count - 1
        var lastDate = candles[lastCandleIndex].date
        
        for i in 1...Int(Double(candles.count)*0.2) {
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
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates) // даты, которые будут отображаться снизу в values
        
        let dataSet = CandleChartDataSet(entries: entries)
        
        dataSet.decreasingColor = .systemGreen
        dataSet.increasingColor = .systemRed
        dataSet.neutralColor = .clear
        dataSet.increasingFilled = true
        dataSet.decreasingFilled = true
        
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 1
        
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false // отключаем значения сверху каждой свечи
        
        dataSet.highlightColor = .systemGray
        dataSet.highlightLineWidth = 1
        dataSet.highlightLineDashLengths = [6]
        
        let data = CandleChartData(dataSet: dataSet)
        chartView.data = data
    }
}

//MARK: - ChartViewDelegate

extension ChartView: ChartViewDelegate {
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("123") // вызывается, когда убираю highlight
        
        // Вызывать delegate?.chartValueSelected и выводить данные за последнюю свечу
    }

    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // entry содержит index x и среднюю цену y (между open и close)
        
        delegate?.chartValueSelected(index: Int(entry.x))
    }
}
