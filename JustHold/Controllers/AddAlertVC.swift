import UIKit
import BetterSegmentedControl
import RealmSwift

final class AddAlertVC: UIViewController {
    
    private var viewModel: AddAlertVCViewModel?
     
    private lazy var scrollView = UIButtonScrollView()
    
    private lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label.withAlphaComponent(0.9)
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        return label
    }()
    
    private lazy var notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "Оповестить, когда стоимость"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var conditionButton: TextIconButton = {
        let button = TextIconButton()
        button.configure(image: UIImage(systemName: "chevron.down"))
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.keyboardType = .numbersAndPunctuation
        textField.leftIndent(x: 15)
        textField.addTarget(self, action: #selector(updateAlertNameTextField), for: .editingChanged)
        return textField
    }()
    
    private lazy var repeatSegmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl()
        control.segments = LabelSegment.segments(withTitles: ["Без повтора", "Повторять"],
                                                          normalFont: .systemFont(ofSize: 16.0),
                                                          normalTextColor: .secondaryLabel,
                                                          selectedFont: .systemFont(ofSize: 16.0),
                                                          selectedTextColor: .label.withAlphaComponent(0.9))
        control.indicatorViewBorderColor = .systemBlue
        control.indicatorViewBorderWidth = 2
        control.indicatorViewBackgroundColor = .clear
        control.indicatorViewInset = 0
        control.animationSpringDamping = 1.0 // no bounce
        return control
    }()
    
    private lazy var pushCheckBox: CheckBoxButton = {
        let button = CheckBoxButton()
        button.configure(label: "Push-уведомления")
        button.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        return button
    }()
    
    private lazy var expireLabel: UILabel = {
        let label = UILabel()
        label.text = "Истекает"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "ru_RU")
        picker.timeZone = .current
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.contentHorizontalAlignment = .left
        picker.tintColor = .systemBlue
        picker.backgroundColor = .tertiarySystemBackground
        picker.paintClear()
        picker.addTarget(self, action: #selector(updateDateButton), for: .valueChanged)
        picker.addTarget(self, action: #selector(datePickerEditingDidBegin), for: .editingDidBegin)
        picker.addTarget(self, action: #selector(datePickerEditingDidEnd), for: .editingDidEnd)
        return picker
    }()
    
    private lazy var dateButton: TextIconButton = {
        let button = TextIconButton()
        button.configure(image: UIImage(systemName: "calendar"))
        return button
    }()
    
    private lazy var timeButton: TextIconButton = {
        let button = TextIconButton()
        button.configure(image: nil)
        return button
    }()
    
    private lazy var expiringCheckBox: CheckBoxButton = {
        let button = CheckBoxButton()
        button.configure(label: "Без срока истечения")
        button.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        return button
    }()
    
    private lazy var alertNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя оповещения"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var alertNameTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.leftIndent(x: 15)
        return textField
    }()
    
    private lazy var alertMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Сообщение"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var alertMessageTextView: UITextView = {
        let textView = UITextView()
        textView.autocorrectionType = .no
        textView.keyboardType = .default
        textView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return textView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Отмена"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        config.background.cornerRadius = 3
        config.background.strokeColor = .systemGray.withAlphaComponent(0.6)
        config.background.backgroundColor = .clear
        config.baseForegroundColor = .systemGray
        button.configuration = config
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveAlertButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        config.background.cornerRadius = 3
        config.background.backgroundColor = .systemBlue
        config.baseForegroundColor = .white
        button.configuration = config
        button.addTarget(self, action: #selector(didTapSaveAlertButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubviews(coinLabel, notifyLabel, conditionButton, priceTextField, repeatSegmentedControl, pushCheckBox, expireLabel, dateButton, timeButton, expiringCheckBox, alertNameLabel, alertNameTextField, alertMessageLabel, alertMessageTextView, cancelButton, saveAlertButton, errorLabel, datePicker)
        
        priceTextField.delegate = self
        alertNameTextField.delegate = self
        alertMessageTextView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        setUpAppearance(for: [priceTextField, repeatSegmentedControl, alertNameTextField, alertMessageTextView])
        fixTabBarVisualEffectBackdropView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: errorLabel.bottom + 150)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalTo(view.layoutMarginsGuide)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).inset(20)
        }
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(coinLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(coinLabel.snp.horizontalEdges)
        }
        conditionButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(notifyLabel.snp.bottom).offset(10)
            make.left.equalTo(notifyLabel.snp.left)
            make.right.equalTo(view.snp.centerX).offset(-5)
        }
        priceTextField.snp.makeConstraints { make in
            make.size.equalTo(conditionButton.snp.size)
            make.centerY.equalTo(conditionButton.snp.centerY)
            make.right.equalTo(notifyLabel.snp.right)
        }
        
        repeatSegmentedControl.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(conditionButton.snp.bottom).offset(25)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        pushCheckBox.snp.makeConstraints { make in
            make.top.equalTo(repeatSegmentedControl.snp.bottom).offset(10)
            make.left.equalTo(notifyLabel.snp.left)
        }
        
        expireLabel.snp.makeConstraints { make in
            make.top.equalTo(pushCheckBox.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        dateButton.snp.makeConstraints { make in
            make.size.equalTo(conditionButton.snp.size)
            make.top.equalTo(expireLabel.snp.bottom).offset(10)
            make.left.equalTo(notifyLabel.snp.left)
        }
        timeButton.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(dateButton.snp.height)
            make.centerY.equalTo(dateButton.snp.centerY)
            make.left.equalTo(priceTextField.snp.left)
        }
        expiringCheckBox.snp.makeConstraints { make in
            make.top.equalTo(dateButton.snp.bottom).offset(10)
            make.left.equalTo(notifyLabel.snp.left)
        }
        
        alertNameLabel.snp.makeConstraints { make in
            make.top.equalTo(expiringCheckBox.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        alertNameTextField.snp.makeConstraints { make in
            make.size.equalTo(repeatSegmentedControl.snp.size)
            make.top.equalTo(alertNameLabel.snp.bottom).offset(10)
            make.left.equalTo(notifyLabel.snp.left)
        }
        
        alertMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(alertNameTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        alertMessageTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(60)
            make.height.lessThanOrEqualTo(180)
            make.top.equalTo(alertMessageLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(130)
            make.top.equalTo(alertMessageTextView.snp.bottom).offset(50)
            make.right.equalTo(view.snp.centerX).offset(-15)
        }
        saveAlertButton.snp.makeConstraints { make in
            make.size.equalTo(cancelButton)
            make.top.equalTo(alertMessageTextView.snp.bottom).offset(50)
            make.left.equalTo(view.snp.centerX).offset(15)
        }
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(notifyLabel.snp.horizontalEdges)
        }
        
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dateButton.snp.centerY)
            make.right.equalTo(timeButton.snp.left).offset(70)
        }
    }
    
    //MARK: - Public
    
    public func configure(with viewModel: AddAlertVCViewModel) {
        self.viewModel = viewModel
        
        coinLabel.text = viewModel.alert.coinName
        updateConditionButtonAndMenu()
        priceTextField.text = viewModel.alert.priceTarget.prepareValue
        repeatSegmentedControl.setIndex(viewModel.alert.notifyJustOnce ? 0 : 1)
        pushCheckBox.isSelected = viewModel.alert.pushNotificationsEnabled
        updateDateButton(datePicker)
        expiringCheckBox.isSelected = viewModel.alert.expirationDateDisabled
        updateAlertNameTextField(self.alertNameTextField)
        alertMessageTextView.text = viewModel.alert.alertMessage
        saveAlertButton.setTitle(viewModel.saveButtonText, for: .normal)
    }
}

// MARK: - Private

private extension AddAlertVC {
    
    func createConditionMenu() -> UIMenu {
        let actions = [
            UIAction(title: AlertModel.Condition.greaterThan.rawValue,
                     state: viewModel?.alert.priceCondition == .greaterThan ? .on : .off,
                     handler: { _ in
                         RealmManager.shared.updateAlert {
                             self.viewModel?.alert.priceCondition = .greaterThan
                         }
                         
                         self.updateConditionButtonAndMenu()
                         self.updateAlertNameTextField(self.alertNameTextField)
                     }),
            UIAction(title: AlertModel.Condition.lessThan.rawValue,
                     state: viewModel?.alert.priceCondition == .lessThan ? .on : .off,
                     handler: { _ in
                         RealmManager.shared.updateAlert {
                             self.viewModel?.alert.priceCondition = .lessThan
                         }
                         
                         self.updateConditionButtonAndMenu()
                         self.updateAlertNameTextField(self.alertNameTextField)
                     })]
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        return menu
    }
    
    @objc func updateConditionButtonAndMenu() {
        conditionButton.menu = createConditionMenu()
        conditionButton.changeLabel(newText: self.viewModel?.alert.priceCondition.rawValue ?? "больше, чем")
    }
    
    @objc func updateAlertNameTextField(_ textField: UITextField) {
        guard let canAutoupdateAlertName = viewModel?.canAutoupdateAlertName, let coinName = viewModel?.alert.coinName, let priceCondition = viewModel?.alert.priceCondition.rawValue.lowercased() else { return }
        
        if canAutoupdateAlertName && viewModel?.alert.alertName == "" {
            alertNameTextField.text = coinName + " " + priceCondition + " " + (priceTextField.text ?? "0")
        }
        else if !canAutoupdateAlertName {
            return
        }
        else {
            alertNameTextField.text = viewModel?.alert.alertName
        }
    }
    
    @objc func didTapCheckBox(_ sender: UIButton){
        sender.isSelected.toggle()
    }
    
    @objc func updateDateButton(_ datePicker: UIDatePicker) {
        dateButton.changeLabel(newText: datePicker.date.toString(dateFormat: "dd MMM yyyy"))
        timeButton.changeLabel(newText: datePicker.date.toString(dateFormat: "HH:mm"))
    }
    
    @objc func datePickerEditingDidBegin(_ datePicker: UIDatePicker) {
        dateButton.isHighlighted = true
        timeButton.isHighlighted = true
    }
    
    @objc func datePickerEditingDidEnd(_ datePicker: UIDatePicker) {
        dateButton.isHighlighted = false
        timeButton.isHighlighted = false
    }
    
    @objc func didTapCancelButton(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSaveAlertButton(_ sender: UIButton) {
        guard let priceString = priceTextField.text, priceString.isNumeric, let priceDouble = Double(priceString) else {
            priceTextField.layer.borderColor = UIColor.systemRed.cgColor
            priceTextField.layer.borderWidth = 2
            errorLabel.isHidden = false
            errorLabel.text = "Значение стоимости должно состоять только из следующих символов: \"0\", \"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\", \"8\", \"9\" и \".\""
            return
        }
        
        guard let alertName = alertNameTextField.text, !alertName.isEmpty else {
            alertNameTextField.layer.borderColor = UIColor.systemRed.cgColor
            alertNameTextField.layer.borderWidth = 2
            errorLabel.isHidden = false
            errorLabel.text = "Введите название оповещения"
            return
        }
        
        // save data
        guard let alert = viewModel?.alert else { return }
        RealmManager.shared.updateAlert {
            alert.priceCondition = alert.priceCondition
            alert.priceTarget = priceDouble
            alert.notifyJustOnce = repeatSegmentedControl.index == 0
            alert.pushNotificationsEnabled = pushCheckBox.isSelected
            alert.expirationDate = datePicker.date
            alert.expirationDateDisabled = expiringCheckBox.isSelected
            alert.alertName = alertName
            alert.alertMessage = alertMessageTextView.text
        }
        
        if viewModel?.purpose == .saveNewAlert {
            guard let alert = viewModel?.alert else { return }
            RealmManager.shared.saveNewAlert(alert)
            showAlert(viewModel: .init(result: .success, text: "Оповещение создано"))
        } else {
            showAlert(viewModel: .init(result: .success, text: "Оповещение изменено"))
        }
        
        HapticsManager.shared.vibrateSlightly()
        navigationController?.popViewController(animated: true)
    }
    
    func setUpAppearance<T>(for views: [T]) {
        for view in views {
            if let view = view as? UIView {
                view.backgroundColor = .clear
                view.layer.cornerRadius = 2
                changeBorderColor(view: view, isSelected: false)
            }
            
            if let view = view as? UITextField {
                view.textColor = .label.withAlphaComponent(0.9)
                view.font = .systemFont(ofSize: 16, weight: .regular)
            }
            if let view = view as? UITextView {
                view.textColor = .label.withAlphaComponent(0.9)
                view.font = .systemFont(ofSize: 16, weight: .regular)
            }
        }
    }
    
    func changeBorderColor<T>(view: T, isSelected: Bool) {
        guard let view = view as? UIView else {
            return
        }
        
        if isSelected {
            view.layer.borderColor = UIColor.systemBlue.cgColor
            view.layer.borderWidth = 2
        } else {
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.6).cgColor
        }
    }
}

//MARK: - UITextFieldDelegate

extension AddAlertVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColor(view: textField, isSelected: true)
        if textField == alertNameTextField {
            viewModel?.canAutoupdateAlertName = false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        changeBorderColor(view: textField, isSelected: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UITextViewDelegate

extension AddAlertVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        changeBorderColor(view: textView, isSelected: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        changeBorderColor(view: textView, isSelected: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.height > 150 {
            textView.frame.size.height = 180
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }

        if textView.contentSize.height < 180 {
            textView.isScrollEnabled = false
            textView.sizeToFit()
        }
    }
}
