import UIKit
import SnapKit

class ChartVC: UIViewController {
    
    public var coinID: Int?
    private var coinQuote: CoinListingData?
    
    private var candles = [Candle]()
    
    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    private var queryParams: (resolution: String, days: TimeInterval) = ("D", 365*2)
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        label.text = "BTC/USDT"
        label.textColor = .label
        return label
    }()
    
    private let rankLabel: RankLabel = {
        let label = RankLabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.text = "1"
        label.frame.size = label.intrinsicContentSize
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .systemGray6
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let exchangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Binance"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let plusLabel: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemYellow
        label.backgroundColor = .systemBackground
        label.textAlignment = .center
        return label
    }()
    
    private let toFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = .clear
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapFavoriteButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private let addAlertButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = .clear
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapAlertButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .null, collectionViewLayout: layout)
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        return collectionView
    }()
    
    private let chartView = ChartView()
    
    private let resolutionSegmentedControl: UISegmentedControl = {
        let items = ["1", "5", "15", "60", "D", "W", "M"]
        let control = UISegmentedControl(items: items)
        control.addTarget(self, action: #selector(resolutionDidChange(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 4
        return control
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PersistenceManager.shared.lastChosenID == 0 {
            PersistenceManager.shared.lastChosenID = 1
        }
        
        view.backgroundColor = .systemBackground
        view.addSubviews(logoView, symbolLabel, rankLabel, exchangeLabel, toFavoriteButton, addAlertButton, plusLabel, chartView, collectionView, resolutionSegmentedControl)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchFinancialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFinancialData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let indent: CGFloat = 30
        
        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalTo(view.snp.top).offset(60)
            make.left.equalTo(view.snp.left).offset(indent)
        }
        toFavoriteButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.right.equalTo(view.snp.right).inset(20)
            make.centerY.equalTo(logoView.snp.centerY)
        }
        addAlertButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.right.equalTo(toFavoriteButton.snp.left).offset(-5)
            make.centerY.equalTo(logoView.snp.centerY)
        }
        plusLabel.snp.makeConstraints { make in
            make.height.width.equalTo(14)
            make.right.equalTo(addAlertButton.snp.right).inset(4)
//            make.bottom.equalTo(addAlertButton).inset(4)
            make.top.equalTo(addAlertButton.snp.top).inset(4)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.top).offset(3)
            make.left.equalTo(logoView.snp.right).offset(20)
            make.right.equalTo(addAlertButton.snp.left).offset(-10)
        }
        rankLabel.snp.makeConstraints { make in
            make.bottom.equalTo(logoView.snp.bottom).inset(2)
            make.left.equalTo(symbolLabel.snp.left).offset(1)
        }
        exchangeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankLabel.snp.centerY)
            make.left.equalTo(rankLabel.snp.right).offset(10)
//            make.right.equalTo(symbolLabel.snp.right) // тогда rankLabel растягивается в ширину, а exchangeLabel сжимается немного
            make.width.equalTo(view.width/3)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(logoView.snp.bottom).offset(20)
            make.left.equalTo(logoView.snp.left)
            make.right.equalTo(toFavoriteButton.snp.right)
        }
        resolutionSegmentedControl.snp.makeConstraints { make in
            make.left.equalTo(logoView.snp.left)
            make.right.equalTo(toFavoriteButton.snp.right)
            make.height.equalTo(30)
            make.top.equalTo(view.height - 130)
        }
        
        chartView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.top.equalTo(collectionView.snp.bottom).offset(15)
            make.bottom.equalTo(resolutionSegmentedControl.snp.top).offset(-20)
        }
    }
    
    //MARK: - Private
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        group.enter() // Fetch Candles
        APICaller.shared.fetchCandles(for: PersistenceManager.shared.lastChosenSymbol,
                                      resolution: queryParams.resolution,
                                      numberOfDays: queryParams.days) { [weak self] candlesData in
            defer {
                group.leave()
            }
            self?.candles = candlesData.candles
        }
        
        group.enter() // FetchQuotes // Можно сменить на поиск по ID в сохраненных монетах, т.к. нужны только rank, name и logoUrl
        APICaller.shared.fetchQuotes(ids: [PersistenceManager.shared.lastChosenID]) { [weak self] metrics in
            defer {
                group.leave()
            }
            self?.coinQuote = metrics[0]
        }
        
        // setUpElements
        group.notify(queue: .main) { [weak self] in
            self?.prepareLogoAndLabels()
            self?.setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: PersistenceManager.shared.lastChosenID))
            self?.prepareMetricViewModels()
            self?.renderChart()
        }
    }
    
    private func setUpFavoriteButton(inFavorites: Bool) {
        if inFavorites {
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        } else {
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
    }
    
    private func prepareLogoAndLabels() {
        logoView.sd_setImage(with: URL(string: coinQuote?.logoUrl ?? ""))
        rankLabel.text = "\(coinQuote?.rank ?? 0)"
        
        for symbol in PersistenceManager.shared.cryptoSymbols {
            if symbol.symbol == PersistenceManager.shared.lastChosenSymbol {
                symbolLabel.text = symbol.displaySymbol
                exchangeLabel.text = (coinQuote?.name ?? "") + "\n" + (symbol.description.components(separatedBy: " ").first ?? "")
                // разбить exchangeLabel на 2 логотипа?
            }
        }
    }
    
    private func prepareMetricViewModels() {
        metricViewModels = []
        let change = candles[0].close - candles[1].close
        let percentChange = ((candles[0].close-candles[1].close)/candles[1].close) * 100
        let sign = change > 0 ? "+" : ""
        
        metricViewModels.append(.init(name: "ОТКР", value: candles[0].open.prepareValue))
        metricViewModels.append(.init(name: "ЗАКР", value: candles[0].close.prepareValue))
        metricViewModels.append(.init(name: "МАКС", value: candles[0].high.prepareValue))
        metricViewModels.append(.init(name: "МИН", value: candles[0].low.prepareValue))
        metricViewModels.append(.init(name: "ОБЪЁМ", value: "$" + String(candles[0].volume.prepareValue)))
        metricViewModels.append(.init(name: "ИЗМ", value: "\(sign)\(change.prepareValue) (\(sign)\(percentChange.preparePercentChange)%)"))
        
        collectionView.reloadData()
    }
    
    private func renderChart() {
        let change = candles.getPercentage()
        chartView.configure(with: ChartView.ViewModel(data: candles.reversed().map { $0.close},
                                                      fillColor: change < 0 ? .systemRed : .systemGreen))
    }
    
    @objc private func resolutionDidChange(_ segmentedControl: UISegmentedControl) {
        HapticsManager.shared.vibrateSlightly()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            queryParams = (resolution: "1", days: 3)
        case 1:
            queryParams = (resolution: "5", days: 10)
        case 2:
            queryParams = (resolution: "15", days: 30)
        case 3:
            queryParams = (resolution: "60", days: 90)
        case 4:
            queryParams = (resolution: "D", days: 365*2)
        case 5:
            queryParams = (resolution: "W", days: 365*4)
        case 6:
            queryParams = (resolution: "M", days: 365*6)
        default:
            queryParams = (resolution: "D", days: 365*2)
        }
        
        fetchFinancialData()
    }
    
    @objc private func didTapFavoriteButton(_: UIButton) {
        HapticsManager.shared.vibrateSlightly()
        let lastID = PersistenceManager.shared.lastChosenID
        
        if PersistenceManager.shared.isInFavorites(coinID: lastID) {
            PersistenceManager.shared.removeFromFavorites(coinID: lastID)
            toFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            toFavoriteButton.tintColor = .systemGray
        }
        else {
            PersistenceManager.shared.favoriteCoinsIDs.append(lastID)
            toFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            toFavoriteButton.tintColor = .systemYellow
        }
    }
    
    @objc private func didTapAlertButton(_: UIButton) {
        HapticsManager.shared.vibrateSlightly()
        
        // показать экран, где добавляется алерт к выбранной монете. Потом этот алерт добавляется в PersistenceManager и выводится в tableView в AlertsVC
        print("надо добавить alert")
    }
}

extension ChartVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModel,
                       color: candles[0].close >= candles[0].open ? .systemGreen : .systemRed)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.width-50)/2, height: 20)
    }
}
