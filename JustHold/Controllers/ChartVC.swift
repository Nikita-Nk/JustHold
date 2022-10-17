import UIKit
import SnapKit
import RAMAnimatedTabBarController
import SkeletonView

class ChartVC: UIViewController {
    
    public var coinID: Int?
    private var coinQuote: CoinListingData!
    
    private var candles = [Candle]()
    
    private var dataForCollView = (color: UIColor.systemGreen, viewModels: [MetricCollectionViewCell.ViewModel]())
    
    private var queryParams: (resolution: String, days: TimeInterval) = ("D", 365*2)
    
    private var isFirstAppearance = true
    
    private let blur: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.alpha = 0
        return blur
    }()
    
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
        label.text = PersistenceManager.shared.lastChosenSymbol.components(separatedBy: ":")[1]
        label.textColor = .label
        return label
    }()
    
    private let rankLabel: RankLabel = {
        let label = RankLabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.frame.size = label.intrinsicContentSize
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .systemGray6
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let exchangeLabel: UILabel = {
        let label = UILabel()
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
        chartView.delegate = self
        
        fetchFinancialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if !isFirstAppearance {
            fetchFinancialData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppearance {
            setUpSkeleton()
        }
        isFirstAppearance = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blur.frame = view.frame
        
        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalTo(view.snp.top).offset(50)
            make.left.equalTo(view.snp.left).offset(15)
        }
        toFavoriteButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.right.equalTo(view.snp.right).inset(15)
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
            make.top.equalTo(addAlertButton.snp.top).inset(4)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.top).offset(3)
            make.left.equalTo(logoView.snp.right).offset(15)
            make.right.equalTo(addAlertButton.snp.left).offset(-10)
        }
        rankLabel.snp.makeConstraints { make in
            make.bottom.equalTo(logoView.snp.bottom).inset(2)
            make.left.equalTo(symbolLabel.snp.left).offset(1)
        }
        exchangeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankLabel.snp.centerY)
            make.left.equalTo(rankLabel.snp.right).offset(10)
            make.right.equalTo(symbolLabel.snp.right)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.top.equalTo(logoView.snp.bottom).offset(20)
            make.left.equalTo(logoView.snp.left)
            make.right.equalTo(view.snp.right).inset(15)
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
        candles = []
        
        group.enter()
        APICaller.shared.fetchCandles(for: PersistenceManager.shared.lastChosenSymbol,
                                      resolution: queryParams.resolution,
                                      numberOfDays: queryParams.days) { [weak self] response in
            defer {
                group.leave()
            }
            
            switch response.result {
            case .success(let candlesResponse):
                self?.candles = candlesResponse.candles.reversed()
            case .failure(let error):
                print(error)
            }
        }
        
        group.enter() // Можно сменить на поиск по ID в сохраненных монетах, т.к. нужны только rank, name и logoUrl
        APICaller.shared.fetchQuotes(ids: [PersistenceManager.shared.lastChosenID]) { [weak self] metrics in
            defer {
                group.leave()
            }
            self?.coinQuote = metrics[0]
        }
        
        // setUpElements
        group.notify(queue: .main) { [weak self] in
            if !(self?.candles.isEmpty ?? false) { // если в запросе нет данных, то не обновляем ничего
                self?.prepareLogoAndLabels()
                self?.setUpFavoriteButton(inFavorites: PersistenceManager.shared.isInFavorites(coinID: PersistenceManager.shared.lastChosenID))
                self?.prepareCollectionViewData()
                self?.renderChart()
                
                defer {
                    self?.removeSkeleton()
                }
            }
            else {
                self?.showAlert()
            }
        }
    }
    
    private func showAlert() {
        view.addSubview(blur)
        UIView.animate(withDuration: 0.4) {
            self.blur.alpha = 0.8
        }
        
        let exchange = PersistenceManager.shared.lastChosenSymbol.components(separatedBy: ":")[0]
        let alert = UIAlertController(title: "К сожалению, данные для выбранной пары на бирже \(exchange) временно не доступны", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Выбрать эту пару на другой бирже", style: .cancel, handler: { action in
            self.blur.removeFromSuperview()
            self.blur.alpha = 0
            if let ramTBC = self.tabBarController as? RAMAnimatedTabBarController {
                ramTBC.setSelectIndex(from: 1, to: 0)
            }
        }))
        present(alert, animated: true)
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
            }
        }
    }
    
    private func prepareCollectionViewData(chosenIndex: Int = -1) {
        
        let lastCandleIndex = candles.count - 1
        var candle = candles[lastCandleIndex]
        
        if chosenIndex == -1 || chosenIndex > lastCandleIndex {
            // если стандартное значение, либо выбранный индекс больше индекса последней свечи, тогда просто оставляем последнюю свечу
        } else { // в остальных случаях показываем свечу по выбранному индексу
            candle = candles[chosenIndex]
        }
        
        let change = candle.close - candle.open
        let percentChange = ((candle.close-candle.open)/candle.open) * 100
        let sign = change > 0 ? "+" : ""
        
        dataForCollView.color = change > 0 ? .systemGreen : .systemRed
        dataForCollView.viewModels = []
        dataForCollView.viewModels.append(.init(name: "ОТКР", value: candle.open.prepareValue))
        dataForCollView.viewModels.append(.init(name: "ЗАКР", value: candle.close.prepareValue))
        dataForCollView.viewModels.append(.init(name: "МАКС", value: candle.high.prepareValue))
        dataForCollView.viewModels.append(.init(name: "МИН", value: candle.low.prepareValue))
        dataForCollView.viewModels.append(.init(name: "ИЗМ",
                                                value: "\(sign)\(change.prepareValue) (\(sign)\(percentChange.preparePercentChange)%)"))
        dataForCollView.viewModels.append(.init(name: "ОБЪЁМ", value: String(candle.volume.prepareValue)))
        dataForCollView.viewModels.append(.init(name: "\(candle.date.toString(dateFormat: "d MMM yyyy HH:mm"))", value: ""))
        
        collectionView.reloadData()
    }
    
    private func renderChart() {
        chartView.configure(with: candles)
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
        let addAlertVC = AddAlertVC()
        addAlertVC.configure(with: .init(purpose: .saveNewAlert,
                                         coinQuote: coinQuote,
                                         candles: candles,
                                         coinSymbol: PersistenceManager.shared.lastChosenSymbol))
        navigationController?.pushViewController(addAlertVC, animated: true)
    }
    
    private func setUpSkeleton() {
        rankLabel.isHidden = true
        exchangeLabel.isHidden = true
        resolutionSegmentedControl.isHidden = true
        let views = [logoView, symbolLabel, plusLabel, toFavoriteButton, addAlertButton, chartView, collectionView]
        for view in views {
            view.isSkeletonable = true
            view.showAnimatedSkeleton(usingColor: .systemGray2,
                                      animation: nil,
                                      transition: .crossDissolve(0.25))
        }
    }
    
    private func removeSkeleton() {
        rankLabel.isHidden = false
        exchangeLabel.isHidden = false
        resolutionSegmentedControl.isHidden = false
        let views = [logoView, symbolLabel, plusLabel, toFavoriteButton, addAlertButton, chartView, collectionView]
        for view in views {
            view.stopSkeletonAnimation()
            view.hideSkeleton()
        }
    }
}

//MARK: - MyChartViewDelegate

extension ChartVC: MyChartViewDelegate {
    func chartValueSelected(index: Int) {
        prepareCollectionViewData(chosenIndex: index)
    }
}

//MARK: - UICollectionViewDelegate

extension ChartVC: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return MetricCollectionViewCell.identifier
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataForCollView.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(with: dataForCollView.viewModels[indexPath.row],
                       color: dataForCollView.color)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.width-40)/2, height: 20) // -40 = по 15 отступ слева и справа и 10 на расстояние между ячейками
    }
}
