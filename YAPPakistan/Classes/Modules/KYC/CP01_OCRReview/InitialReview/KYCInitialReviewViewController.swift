//
//  KYCInitialReviewViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 28/09/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCInitialReviewViewController: UIViewController {

    // MARK: Views

    private lazy var titleLabel = UIFactory.makeLabel(
        font: .title2,
        alignment: .center,
        text: "screen_kyc_initial_review_screen_title".localized)

    private lazy var subHeadingLabel = UIFactory.makeLabel(
        font: .regular,
        alignment: .center,
        numberOfLines: 0,
        lineBreakMode: .byWordWrapping)

    private lazy var cardView: KYCDocumentView = {
        let view = KYCDocumentView()
        view.viewType = .detailsOnly
        view.title = "screen_kyc_initial_review_cnic_number".localized
        view.details = ""
        view.icon = UIImage(named: "kyc-user", in: .yapPakistan)
        return view
    }()

    private lazy var issueDateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var issueDateHeadingLabel = UIFactory.makeLabel(
        font: .small, alignment: .natural, numberOfLines: 1)

    private lazy var issueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date

        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }

        return picker
    }()

    private lazy var issueDateField: UITextField = {
        let textField = UITextField()
        textField.font = .large
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.textAlignment = .natural
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = issueDatePicker
        return textField
    }()

    private lazy var valueField = UIFactory.makeLabel(
        font: .large, alignment: .natural, numberOfLines: 1)

    private lazy var tickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_check", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var confirmButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title = "common_button_confirm".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var reScanButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_kyc_initial_review_rescan".localized, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: Properties

    private let disposeBag = DisposeBag()
    private let themeService: ThemeService<AppTheme>

    let viewModel: KYCInitialReviewViewModelType

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: KYCInitialReviewViewModelType) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Unsupported")
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(cardView)
        view.addSubview(issueDateContainer)
        view.addSubview(bottomStack)

        issueDateContainer.addSubview(issueDateHeadingLabel)
        issueDateContainer.addSubview(issueDateField)
        issueDateContainer.addSubview(tickImageView)

        bottomStack.addArrangedSubview(confirmButton)
        bottomStack.addArrangedSubview(reScanButton)

        view.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)

        issueDatePicker.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let date = self.issueDatePicker.date
                self.viewModel.inputs.issueDateObserver.onNext(date)
            })
            .disposed(by: disposeBag)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeadingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.iconTintColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.titleColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.detailsColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.subTitleColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.subDetailsColor)
            .bind({ UIColor($0.greyDark) }, to: issueDateHeadingLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: issueDateField.rx.textColor)
            .bind({ UIColor($0.primary) }, to: confirmButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: confirmButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: reScanButton.rx.titleColorForNormal)
            .bind({ UIColor($0.primaryLight) }, to: tickImageView.rx.tintColor)
            .disposed(by: disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [20, 20, 20])

        subHeadingLabel
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .toBottomOf(titleLabel, constant: 10)

        cardView
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
//            .height(constant: 70)
            .toBottomOf(subHeadingLabel, constant: 35)

        issueDateContainer
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])
            .toBottomOf(cardView, constant: 25)
            .height(constant: 64)

        issueDateHeadingLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [20, 20, 8])

        issueDateField
            .alignEdgeWithSuperview(.left, constant: 20)
            .toBottomOf(issueDateHeadingLabel)
            .alignEdgeWithSuperview(.bottom, constant: 8)

        tickImageView
            .toRightOf(issueDateField)
            .alignEdgeWithSuperview(.right, constant: 20)
            .centerVerticallyWith(issueDateField)
            .width(constant: 32)
            .height(constant: 32)

        bottomStack
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)

        confirmButton
            .width(constant: 190)
            .height(constant: 52)

        reScanButton
            .height(constant: 30)
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.subHeadingText
            .bind(to: subHeadingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.cnicNumber
            .bind(to: cardView.rx.details)
            .disposed(by: disposeBag)

        viewModel.outputs.issueDateTitle
            .bind(to: issueDateHeadingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.issueDateValue
            .bind(to: issueDateField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: disposeBag)

        confirmButton.rx.tap
            .bind(to: viewModel.inputs.confirmObserver)
            .disposed(by: disposeBag)

        reScanButton.rx.tap
            .bind(to: viewModel.inputs.rescanObserver)
            .disposed(by: disposeBag)
    }
}
