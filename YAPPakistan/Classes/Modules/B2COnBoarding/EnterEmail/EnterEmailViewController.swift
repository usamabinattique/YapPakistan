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

class EnterEmailViewController: OnBoardinContainerChildViewController {
    
    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .title2)
        label.textColor = UIColor.blue //appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .regular)
        label.textColor = UIColor.darkGray //appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.text = "screen_enter_email_b2b_display_text_sub_heading".localized
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorLabel:UILabel = {
        let label = UIFactory.makeLabel(alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
        label.textColor = .darkGray //with: .greyDark
                                    //textStyle: .micro,
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var email: AppRoundedTextField = {
        let textField = AppRoundedTextField()
        textField.placeholder = "screen_enter_email_display_text_email_address".localized
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var verificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .regular)
        label.textColor = .darkGray //UIColor.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    override var firstReponder: UITextField? {
        return email
    }
    
    private var viewModel: EnterEmailViewModelType!
    private var onBoardingStage: OnboardingStage = .email
    
    // MARK: Initialization
    
    init(viewModel: EnterEmailViewModelType!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
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
    
    /* override func didPopFromNavigationController() {
        ///viewModel.inputs.poppedObserver.onNext(())
        ///guard let errorText = errorLabel.text else { return }
        ///if errorText.count > 0 {
        ///    AppAnalytics.shared.logEvent(OnBoardingEvent.signupEmailFailure())
        ///}
    } */
    
}

// MARK: View setup

private extension EnterEmailViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(subHeadingLabel)
        view.addSubview(email)
        view.addSubview(errorLabel)
        view.addSubview(verificationLabel)
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
        
        errorLabel
            .toBottomOf(email, constant: -20)
            .alignEdges([.left, .right], withView: email, constant: 15)
    }
}

// MARK: Binding

private extension EnterEmailViewController {
    func bindViews() {
        
        email.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.endEditting.bind(to: view.rx.endEditting).disposed(by: rx.disposeBag)
        viewModel.outputs.emailValidation.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.emailValidation.map{ $0 != .invalid }.bind(to: errorLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.bind(to: errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map { _ in AppRoundedTextFieldValidation.invalid }.bind(to: email.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map{ _ in false }.bind(to: errorLabel.rx.isHidden).disposed(by: rx.disposeBag)
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
        email.isUserInteractionEnabled = false
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
