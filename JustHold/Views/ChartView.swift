import UIKit
import Charts

//MARK: - MyChartViewDelegate

protocol MyChartViewDelegate: AnyObject {
    func chartValueSelected(index: Int)
}

//MARK: - ChartView

final class ChartView: UIView {
    
    weak var delegate: MyChartViewDelegate?
    
    private lazy var chartView: CandleStickChartView = {
        let chart = CandleStickChartView()
        chart.backgroundColor = .systemBackground
        chart.xAxis.axisLineColor = .systemBackground
        chart.rightAxis.axisLineColor = .systemBackground
        chart.rightAxis.gridColor = .systemGray4
        chart.xAxis.gridColor = .systemGray4
        chart.legend.enabled = false
        chart.minOffset = 0
        
        chart.xAxis.granularity = 3.0
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .systemFont(ofSize: 12, weight: .bold)
        chart.xAxis.setLabelCount(4, force: false)
//        chart.xAxis.labelTextColor = .white
        
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = true
        chart.rightAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        chart.rightAxis.setLabelCount(12, force: false)
        chart.rightAxis.labelPosition = .outsideChart
        
        chart.doubleTapToZoomEnabled = false
//        chart.addGestureRecognizer() // например, на долгое нажатие включать перекрестие
        
        chart.zoom(scaleX: 1.01, scaleY: 0, x: 0, y: 0)
        
        chart.drawMarkers = true
//        chart.marker
        
        return chart
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
    
    //MARK: - Public
    
    public func reset() {
        chartView.data = nil
    }
    
    public func configure(with viewModel: ChartViewViewModel) {
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.dates)
        let dataSet = CandleChartDataSet(entries: viewModel.entries)
        
        dataSet.decreasingColor = .systemRed
        dataSet.increasingColor = .systemGreen
        dataSet.neutralColor = .clear
        dataSet.increasingFilled = true
        dataSet.decreasingFilled = true
        
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 1
        
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        
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
        HapticsManager.shared.vibrateSlightly()
        delegate?.chartValueSelected(index: -1)
    }

    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        HapticsManager.shared.vibrateSlightly()
        delegate?.chartValueSelected(index: Int(entry.x))
    }
}
