import UIKit
import BetterSegmentedControl
import Lottie

final class AlertsVC: UIViewController {
    
    private var alerts = RealmManager.shared.fetchAllAlerts()
    
    private var calledAlerts: [CalledAlertModel] = []
    
    private let tableViewsSegmentedControl: UISegmentedControl = {
        let items = ["Список", "История"]
        let control = UISegmentedControl(items: items)
        control.addTarget(self, action: #selector(changeTableView(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let alertsTableView: UITableView = {
        let table = UITableView()
        table.register(AlertTableViewCell.self, forCellReuseIdentifier: AlertTableViewCell.identifier)
        return table
    }()
    
    private let alertsHistoryTableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "calledAlertCell")
        return table
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Пусто"
        label.textColor = .label.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private let animationView: AnimationView = {
        let animation = AnimationView()
        animation.animation = Animation.named("emptyBoxAnimation")
        animation.backgroundColor = .clear
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1.0
        return animation
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Оповещения"
        navigationController?.title = ""
        view.backgroundColor = .systemBackground
        view.addSubviews(tableViewsSegmentedControl, alertsTableView, alertsHistoryTableView, emptyLabel, animationView)
        
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        alertsHistoryTableView.delegate = self
        alertsHistoryTableView.dataSource = self
        
        showCalledAlertsExamples()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alerts = RealmManager.shared.fetchAllAlerts()
        alertsTableView.reloadData()
        changeTableView(tableViewsSegmentedControl)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        alertsTableView.isEditing = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewsSegmentedControl.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).inset(20)
        }
        alertsTableView.snp.makeConstraints { make in
            make.top.equalTo(tableViewsSegmentedControl.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.snp.horizontalEdges)
            make.bottom.equalTo(view.snp.bottom)
        }
        alertsHistoryTableView.snp.makeConstraints { make in
            make.edges.equalTo(alertsTableView.snp.edges)
        }
        
        animationView.snp.makeConstraints { make in
            make.top.equalTo(tableViewsSegmentedControl.snp.bottom)
            make.bottom.equalTo(view.snp.bottom)
            make.horizontalEdges.equalTo(view.snp.horizontalEdges)
        }
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.centerY).offset(-240)
            make.width.centerX.equalTo(view.layoutMarginsGuide)
        }
    }
    
    //MARK: - Private
    
    @objc private func changeTableView(_ segmentedControl: UISegmentedControl) {
        HapticsManager.shared.vibrateSlightly()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            alertsHistoryTableView.isHidden = true
            if alerts.isEmpty {
                emptyLabel.isHidden = false
                animationView.isHidden = false
                animationView.play()
                navigationItem.rightBarButtonItem = nil
            } else {
                alertsTableView.isHidden = false
                emptyLabel.isHidden = true
                animationView.stop()
                animationView.isHidden = true
                setUpReorderAlertsBarButton()
            }
        case 1:
            alertsTableView.isHidden = true
            alertsTableView.isEditing = false
            if calledAlerts.isEmpty {
                emptyLabel.isHidden = false
                animationView.isHidden = false
                animationView.play()
                navigationItem.rightBarButtonItem = nil
            } else {
                emptyLabel.isHidden = true
                animationView.isHidden = true
                animationView.stop()
                alertsHistoryTableView.isHidden = false
                setUpClearAlertsHistoryBarButton()
            }
        default:
            print("changeTableView")
        }
    }
    
    private func setUpReorderAlertsBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Изменить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapReorderAlerts))
    }
    
    private func setUpClearAlertsHistoryBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapClearAlertsHistory))
    }
    
    @objc private func didTapReorderAlerts() {
        HapticsManager.shared.vibrate(for: .success)
        if alertsTableView.isEditing {
            alertsTableView.isEditing = false
            navigationItem.rightBarButtonItem?.title = "Изменить"
        } else {
            alertsTableView.isEditing = true
            navigationItem.rightBarButtonItem?.title = "Сохранить"
        }
    }
    
    @objc private func didTapClearAlertsHistory() {
        calledAlerts = []
        alertsHistoryTableView.reloadData()
        changeTableView(tableViewsSegmentedControl)
        HapticsManager.shared.vibrate(for: .success)
    }
    
    private func showCalledAlertsExamples() { // для примера
        calledAlerts = [.init(alertName: "BNBUSDT больше 350.7",
                              coinName: "BNB",
                              callDate: Date()),
                        .init(alertName: "SOLUSDT меньше 35.30",
                              coinName: "SOL",
                              callDate: Date())]
    }
}

//MARK: - UITableViewDelegate

extension AlertsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateSlightly()
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == alertsTableView {
            let alert = alerts[indexPath.row]
            let addAlertVC = AddAlertVC()
            addAlertVC.configure(with: .init(purpose: .editExistingAlert, alert: alert))
            navigationController?.pushViewController(addAlertVC, animated: true)
        } else {
//            calledAlerts[indexPath.row].isChecked = true
        }
    }
}

//MARK: - UITableViewDataSource

extension AlertsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            alertsTableView.beginUpdates()
            RealmManager.shared.deleteAlert(alerts[indexPath.row])
            alerts.remove(at: indexPath.row)
            alertsTableView.deleteRows(at: [indexPath], with: .fade)
            alertsTableView.endUpdates()
            changeTableView(tableViewsSegmentedControl)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        try! Realm().write {
////            alerts.swapAt(sourceIndexPath.row, destinationIndexPath.row)
////            swap(&alerts[sourceIndexPath.row], &alerts[destinationIndexPath.row])
//            alerts.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == alertsTableView ? alerts.count : calledAlerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == alertsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlertTableViewCell.identifier, for: indexPath) as? AlertTableViewCell else {
                return AlertTableViewCell()
            }
            let alert = alerts[indexPath.row]
            cell.configure(with: .init(alert))
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calledAlertCell", for: indexPath)
            cell.backgroundColor = .systemBackground
            let calledAlert = calledAlerts[indexPath.row]
            var configuration = cell.defaultContentConfiguration()
            configuration.text = calledAlert.alertName
            configuration.secondaryText = calledAlert.coinName + "  •  " + calledAlert.callDate.toString(dateFormat: "dd MMM HH:mm")
            cell.contentConfiguration = configuration
            return cell
        }
    }
}

//MARK: - AlertTableViewCellDelegate

extension AlertsVC: AlertTableViewCellDelegate {
    
    func showErrorAlert() {
        showAlert(viewModel: .init(result: .failure, text: "Обновите срок действия оповещения или отключите дату истечения"))
    }
}
