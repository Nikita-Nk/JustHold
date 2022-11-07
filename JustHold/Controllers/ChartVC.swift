import UIKit
import SnapKit
import RAMAnimatedTabBarController
import SkeletonView

class ChartVC: UIViewController {
    
    let viewModel = ChartVCViewModel()
    
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
    
    private var timer = Timer()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(logoView, symbolLabel, rankLabel, exchangeLabel, toFavoriteButton, addAlertButton, plusLabel, chartView, collectionView, resolutionSegmentedControl)
        collectionView.delegate = self
        collectionView.dataSource = self
        chartView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        prepareAllData()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateFinancialData), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isFirstAppearance {
            setUpSkeleton()
            viewModel.isFirstAppearance = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
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
    
    private func prepareAllData() {
        viewModel.prepareAllData { [self] isSuccess in
            if isSuccess {
                defer {
                    removeSkeleton()
                }
                viewModel.prepareCollectionViewData(completion: {})
                prepareLogoAndLabels()
                setUpFavoriteButton(inFavorites: viewModel.isInFavorites)
                renderChart()
            }
            else {
                showAlert()
            }
        }
    }
    
    @objc private func updateFinancialData() {
        viewModel.fetchFinancialData { [self] isSuccess in
            if isSuccess {
                viewModel.prepareCollectionViewData(chosenIndex: viewModel.selectedChartIndex, completion: {})
                collectionView.reloadData()
                renderChart()
            }
            else {
//                showAlert()
            }
        }
    }
    
    private func showAlert() {
        view.addSubview(blur)
        UIView.animate(withDuration: 0.4) {
            self.blur.alpha = 0.8
        }
        
        let alert = UIAlertController(title: "К сожалению, данные для выбранной пары на бирже \(viewModel.exchange ?? "") временно не доступны", message: nil, preferredStyle: .alert)
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
        logoView.sd_setImage(with: URL(string: viewModel.logoURL))
        rankLabel.text = viewModel.coinRank
        symbolLabel.text = viewModel.symbolLabelText
        exchangeLabel.text = viewModel.exchangeLabelText
    }
    
    private func renderChart() {
        chartView.configure(with: .init(candles: viewModel.candles))
    }
    
    @objc private func resolutionDidChange(_ segmentedControl: UISegmentedControl) {
        HapticsManager.shared.vibrateSlightly()
        viewModel.resolutionDidChange(index: segmentedControl.selectedSegmentIndex) {
            updateFinancialData()
        }
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
                                         coinName: viewModel.coinName,
                                         candles: viewModel.candles))
        navigationController?.pushViewController(addAlertVC, animated: true)
    }
    
    private func setUpSkeleton() {
        rankLabel.isHidden = true
        exchangeLabel.isHidden = true
        resolutionSegmentedControl.isHidden = true
        
        let views = [logoView, symbolLabel, plusLabel, toFavoriteButton, addAlertButton, chartView, collectionView]
        for view in views {
            view.isSkeletonable = true
            view.showSkeleton(usingColor: .systemGray2, transition: .none)
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
        viewModel.selectedChartIndex = index
        viewModel.prepareCollectionViewData(chosenIndex: index, completion: {
            collectionView.reloadData()
        })
    }
}

//MARK: - SkeletonCollectionViewDataSource

extension ChartVC: SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return MetricCollectionViewCell.identifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionViewCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel.collectionViewCellViewModels[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ChartVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.width-40)/2, height: 20) // -40 = по 15 отступ слева и справа и 10 на расстояние между ячейками
    }
}
