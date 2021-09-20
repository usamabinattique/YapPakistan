//
//  EnterEmailViewController.swift
//  YAP
//
//  Created by Zain on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents

import RxSwift
import RxCocoa
import RxTheme

class EnterEmailViewController: OnBoardinContainerChildViewController {

    fileprivate lazy var headingLabel = UIFactory.makeLabel(font: .title2,
                                                            alignment: .center,
                                                            numberOfLines: 0,
                                                            lineBreakMode: .byWordWrapping,
                                                            text: "screen_enter_email_b2b_display_text_sub_heading".localized,
                                                            adjustFontSize: true)

    fileprivate lazy var subHeadingLabel = UIFactory.makeLabel(font: .regular,
                                                               alignment: .center,
                                                               numberOfLines: 0,
                                                               lineBreakMode: .byWordWrapping,
                                                               text: "screen_enter_email_b2b_display_text_sub_heading".localized,
                                                               adjustFontSize: true)

    fileprivate lazy var stackView = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 11)

    fileprivate lazy var email = UIFactory.makeAppRoundedTextField(with: .regular,
                                                                   errorFont: .micro,
                                                                   placeholder: "screen_enter_email_display_text_email_address".localized,
                                                                   validImage: UIImage(named: "icon_check", in: .yapPakistan),
                                                                   inValidImage: UIImage(named: "icon_invalid", in: .yapPakistan),
                                                                   returnKeyType: .next,
                                                                   autocorrectionType: .no,
                                                                   autocapitalizationType: .none,
                                                                   keyboardType: .emailAddress,
                                                                   delegate: self)

    fileprivate lazy var verificationLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, alpha: 0, adjustFontSize: true)

    override var firstReponder: UITextField? { email }

    fileprivate var viewModel: EnterEmailViewModelType!
    fileprivate var themeService: ThemeService<AppTheme>!
    fileprivate var onBoardingStage: OnboardingStage = .email

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: EnterEmailViewModelType!) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(true)
        viewModel.inputs.stageObserver.onNext(onBoardingStage)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(false)
    }

     override func didPopFromNavigationController() {
        viewModel.inputs.poppedObserver.onNext(())
        // guard let errorText = errorLabel.text else { return }
        // if errorText.count > 0 {
        // AppAnalytics.shared.logEvent(OnBoardingEvent.signupEmailFailure())
        // }
    }

}

// MARK: View setup

private extension EnterEmailViewController {
    func setupViews() {
        view.backgroundColor = .white

        view.addSubview(stackView)
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(subHeadingLabel)
        view.addSubview(email)
        view.addSubview(verificationLabel)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [subHeadingLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [verificationLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [email.rx.primaryColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [email.rx.secondaryColor])
            .bind({ UIColor($0.greyLight      ) }, to: [email.rx.bgColor])
            .bind({ UIColor($0.error          ) }, to: [email.rx.errorColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        subHeadingLabel
            .height(constant: 24)

        stackView
            .alignEdgesWithSuperview([.left, .right, .top], constants: [25, 25, 30])

        email
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(stackView, .lessThanOrEqualTo, constant: 60)
            .toBottomOf(stackView, .greaterThanOrEqualTo, constant: 20)
            .height(constant: 86)

        verificationLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(email, constant: 40)
    }
}

// MARK: Binding

private extension EnterEmailViewController {
    func bindViews() {

        email.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.endEditting.bind(to: view.rx.endEditting).disposed(by: rx.disposeBag)
        viewModel.outputs.emailValidation.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.emailValidation.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: email.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.bind(to: email.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map { _ in AppRoundedTextFieldValidation.invalid(nil) }.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map{ _ in AppRoundedTextFieldValidation.invalid(nil) }.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeadingHidden.bind(to: subHeadingLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.verificationText.bind(to: verificationLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.demographicsSuccess.subscribe(onNext: { [weak self] in self?.animateVerificationText() }).disposed(by: rx.disposeBag)
    }
}

// MARK: Animation

private extension EnterEmailViewController {
    func animateVerificationText() {
        onBoardingStage = .emailVerify
        subHeadingLabel.text = ""
        self.email.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1.0) { [unowned self] in
            self.verificationLabel.alpha = 1.0
        }
    }
}

// MARK: Text field delegate

extension EnterEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.inputs.keyboardNextObserver.onNext(())
        return false
    }
}
