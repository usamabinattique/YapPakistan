//
//  CustomDateStatementViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 06/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxDataSources
import RxTheme

class CustomDateStatementViewController: UIViewController {
    
    //MARK: Views
    private lazy var statementTitle = UIFactory.makeLabel(font: .micro, text: "Export a statement between specific dates")
    
    //Start Date
    private lazy var startDateTitle = UIFactory.makeLabel(font: .regular, text: "Starting on")
    private lazy var startDateCalendarIcon = UIFactory.makeImageView()
    private lazy var startDateTextField: UITextField = {
        let textField = UITextField()
        textField.font = .regular
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.tintColor = .clear
        textField.textAlignment = .natural
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Select date"
        textField.inputView = startDatePicker
        return textField
    }()
    private lazy var startDateSeparator = UIFactory.makeView()
    private lazy var startDateIconFieldStackView = UIFactory.makeStackView(axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 12, arrangedSubviews: [startDateCalendarIcon, startDateTextField])
    
    private lazy var startDateStackView = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 3, arrangedSubviews: [startDateTitle, startDateIconFieldStackView, startDateSeparator])
    
    
    //End Date
    private lazy var endDateTitle = UIFactory.makeLabel(font: .regular, text: "Ending on")
    private lazy var endDateCalendarIcon = UIFactory.makeImageView()
    private lazy var endDateTextField: UITextField = {
        let textField = UITextField()
        textField.font = .regular
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.tintColor = .clear
        textField.textAlignment = .natural
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Select date"
        textField.inputView = endDatePicker
        return textField
    }()
    private lazy var endDateSeparator = UIFactory.makeView()
    private lazy var endDateIconFieldStackView = UIFactory.makeStackView(axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 12, arrangedSubviews: [endDateCalendarIcon, endDateTextField])
    
    private lazy var endDateStackView = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 3, arrangedSubviews: [endDateTitle, endDateIconFieldStackView, endDateSeparator])
    
    private lazy var generateStatementButton = UIFactory.makeAppRoundedButton(with: .large, title: "Generate statement")
    
    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }

        return picker
    }()
    
    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }

        return picker
    }()
    
    private var backButton: UIButton!
    
    //MARK: Properties
    let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: CustomDateStatementViewModelType!
    
    //MARK: initialization
    init(themeService: ThemeService<AppTheme>, viewModel: CustomDateStatementViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
        
        startDateCalendarIcon.image = UIImage(named: "icon_calendar", in: .yapPakistan) ?? UIImage()
        endDateCalendarIcon.image = UIImage(named: "icon_calendar", in: .yapPakistan) ?? UIImage()
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = addBackButton(of: .backEmpty)
    }
    
}

extension CustomDateStatementViewController: ViewDesignable {
    func setupSubViews() {
        view.addSubview(statementTitle)
        view.addSubview(startDateStackView)
        view.addSubview(endDateStackView)
        view.addSubview(generateStatementButton)
    }
    
    func setupConstraints() {
        statementTitle
            .alignEdgesWithSuperview([.top, .left, .right], constants: [30, 24, 24])
            .height(constant: 18)
            
        startDateTitle
            .height(constant: 20)
        
        startDateCalendarIcon
            .width(constant: 20)
            .height(constant: 20)
        
        startDateStackView
            .toBottomOf(statementTitle, constant: 34)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        endDateTitle
            .height(constant: 20)
        
        endDateCalendarIcon
            .width(constant: 20)
            .height(constant: 20)
        
        endDateStackView
            .toBottomOf(startDateStackView, constant: 21)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        startDateSeparator
            .height(constant: 1)
        
        endDateSeparator
            .height(constant: 1)
        
        generateStatementButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 25)
            .centerHorizontallyInSuperview()
            .width(constant: 285)
            .height(constant: 53)
    }
    
    func setupBindings() {
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        
        viewModel.outputs.startDateValue.bind(to: startDateTextField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.endDateValue.bind(to: endDateTextField.rx.text).disposed(by: disposeBag)
        
        view.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)

        startDatePicker.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let date = self.startDatePicker.date
                self.viewModel.inputs.startDateObserver.onNext(date)
            })
            .disposed(by: disposeBag)
        
        endDatePicker.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let date = self.endDatePicker.date
                self.viewModel.inputs.endDateObserver.onNext(date)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isDateValid.bind(to: generateStatementButton.rx.isEnabled).disposed(by: rx.disposeBag)
        generateStatementButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: statementTitle.rx.textColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .bind({ UIColor($0.greyLight) }, to: generateStatementButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: generateStatementButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: generateStatementButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primaryDark) }, to: startDateTitle.rx.textColor)
            .bind({ UIColor($0.separatorColor).withAlphaComponent(0.10) }, to: startDateSeparator.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: endDateTitle.rx.textColor)
            .bind({ UIColor($0.separatorColor).withAlphaComponent(0.10) }, to: endDateSeparator.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}
