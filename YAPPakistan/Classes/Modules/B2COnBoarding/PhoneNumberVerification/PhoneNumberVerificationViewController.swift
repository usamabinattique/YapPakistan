//
//  PhoneNumberVerificationViewController.swift
//  YAP
//
//  Created by Zain on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit

import YAPComponents
import RxSwift
import RxCocoa
import RxTheme
// import AppAnalytics

class PhoneNumberVerificationViewController: OnBoardinContainerChildViewController {

    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "screen_verify_phone_number_display_text_title".localized
        label.font = UIFont.title2
        // label.textColor = UIColor.blue //.appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular
        // label.textColor = UIColor.darkGray //.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var codeTextField: CodeVerificationTextField = {
        let codeTextField = CodeVerificationTextField()
        codeTextField.numberOfTextFields = 6
        codeTextField.delegate = self
        return codeTextField
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .micro
        // label.textColor = UIColor.darkGray //.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var resendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        // button.setTitleColor(UIColor.blue /*.appColor(ofType: .primary)*/, for: .normal)
        button.titleLabel?.font = .large
        button.setTitle( "screen_verify_phone_number_button_resend_otp".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override var firstReponder: UITextField? {
        return codeTextField
    }

    private var viewModel: PhoneNumberVerificationViewModelType!
    private var themeService:ThemeService<AppTheme>!

    init(themeService:ThemeService<AppTheme>, viewModel: PhoneNumberVerificationViewModelType?) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.inputs.viewAppearedObserver.onNext(true)
        viewModel?.inputs.stageObserver.onNext(.otp)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()

    }

    override func didPopFromNavigationController() {
        viewModel?.inputs.poppedObserver.onNext(())
    }

}

// MARK: View setup

extension PhoneNumberVerificationViewController {
    func setupViews() {
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(codeTextField)
        view.addSubview(resendButton)
        view.addSubview(timerLabel)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [subHeadingLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [timerLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [resendButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark        ) }, to: [resendButton.rx.titleColorForDisabled])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        headingLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 30)

        subHeadingLabel
            .toBottomOf(headingLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constant: 35)

        codeTextField
            .toBottomOf(subHeadingLabel, .lessThanOrEqualTo, constant: 55)
            .toBottomOf(subHeadingLabel, .greaterThanOrEqualTo, constant: 15)
            .height(constant: 64)
            .centerHorizontallyInSuperview()

        timerLabel
            .toBottomOf(codeTextField, .lessThanOrEqualTo, constant: 30)
            .toBottomOf(codeTextField, .greaterThanOrEqualTo, constant: 10)
            .centerHorizontallyInSuperview()

        resendButton
            .toBottomOf(timerLabel, constant: 13)
            .height(constant: 33)
            .width(constant: 180)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 12)
            .centerHorizontallyInSuperview()
    }
}

// MARK: Binding

private extension PhoneNumberVerificationViewController {
    func bindViews() {
        guard let viewModel = viewModel else { return }
        
        codeTextField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.timerText.bind(to: timerLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.phoneNumber.bind(to: subHeadingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.endEditting.bind(to: view.rx.endEditting).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map{ _ in }.bind(to: codeTextField.rx.clear).disposed(by: rx.disposeBag)
        viewModel.outputs.showAlert.do(onNext: { [weak self] text in
            self?.showAlert(title: "",
                            message: text,
                            defaultButtonTitle: "common_button_ok".localized,
                            secondayButtonTitle: nil,
                            defaultButtonHandler: { [weak self] _ in _ = self?.codeTextField.becomeFirstResponder() },
                            secondaryButtonHandler: nil,
                            completion: nil )
        }).subscribe().disposed(by: rx.disposeBag)

        viewModel.outputs.resendActive
            .subscribe(onNext:{ [weak self] isEnabled in
                self?.resendButton.isEnabled = isEnabled
                
            })
            .disposed(by: rx.disposeBag)
        viewModel.outputs.resendActive.map { $0 ? 1.0 : 0.3 }.bind(to: resendButton.rx.alpha).disposed(by: rx.disposeBag)
        resendButton.rx.tap.bind(to: viewModel.inputs.resendObserver).disposed(by: rx.disposeBag)
    }
}

// MARK: Text field delegate

extension PhoneNumberVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return (range.location < codeTextField.numberOfTextFields) && allowedCharacters.isSuperset(of: characterSet)
    }
}
