//
//  LoginViewController.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class LoginViewController: UIViewController {

    private var backButton: UIButton?
    private lazy var topImage = UIFactory.makeImageView(contentMode: .scaleToFill)
    private lazy var logo = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var headingLabel = UIFactory.makeLabel(font: .large, alignment: .center)
    private lazy var rememberIDLabel = UIFactory.makeLabel(font: .small)
    private lazy var rememberIDSwitch = UIFactory.makeAppSwitch(isOn: true)
    private lazy var signInButton = UIFactory.makeAppRoundedButton(with: .regular)
    private lazy var signUpContainer = UIFactory.makeView()
    private lazy var signUpLabel = UIFactory.makeLabel( font: .regular )
    private lazy var signUpButton = UIFactory.makeButton( with: .regular )
    private lazy var stackView = UIFactory.makeStackView( axis: .horizontal,
                                                          alignment: .center,
                                                          distribution: .fill,
                                                          spacing: 10 )
    private lazy var mobileNumber = UIFactory.makeAppRoundedTextField( with: .regular,
                                                                       errorFont: .micro,
                                                                       displaysIcon: true,
                                                                       returnKeyType: .send,
                                                                       autocorrectionType: .no,
                                                                       keyboardType: .asciiCapableNumberPad,
                                                                       delegate: self )

    private var signInButtonBottomConstraint: NSLayoutConstraint!
    private var themeService: ThemeService<AppTheme>!
    var viewModel: LoginViewModelType!

    init(themeService: ThemeService<AppTheme>, viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.navigationController?.viewControllers.count ?? 0) > 1 { self.backButton = self.addBackButton() }
        setupSubViews()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
        setupBindings()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeForKeyboardNotifications()
        mobileNumber.resignFirstResponder()
    }
 }

fileprivate extension LoginViewController {

    func setupSubViews() {
        view.addSubview(topImage)
        view.addSubview(logo)
        view.addSubview(headingLabel)
        view.addSubview(mobileNumber)
        view.addSubview(stackView)
        stackView.addArrangedSubview(rememberIDLabel)
        stackView.addArrangedSubview(rememberIDSwitch)
        view.addSubview(signInButton)
        view.addSubview(signUpContainer)
        signUpContainer.addSubview(signUpLabel)
        signUpContainer.addSubview(signUpButton)
    }

    func setupResources() {
        logo.image = UIImage(named: "icon_app_logo", in: .yapPakistan)
        mobileNumber.validInputImage = UIImage(named: "icon_check", in: .yapPakistan)
        mobileNumber.invalidInputImage = UIImage(named: "icon_invalid", in: .yapPakistan)
        topImage.image = UIImage(named: "image_backgound", in: .yapPakistan)
        rememberIDSwitch.onImage = UIImage(named: "icon_check", in: .yapPakistan)?.asTemplate
    }

    func setupLocalizedStrings() {
        viewModel.outputs.localizedText.withUnretained(self).subscribe { `self`, string in
            self.headingLabel.text = string.heading
            self.rememberIDLabel.text = string.remember
            self.signUpLabel.text = string.create
            self.signInButton.setTitle(string.signIn, for: .normal)
            self.signUpButton.setTitle(string.signUp, for: .normal)
        }.disposed(by: rx.disposeBag)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [mobileNumber.rx.primaryColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [mobileNumber.rx.secondaryColor])
            .bind({ UIColor($0.greyLight      ) }, to: [mobileNumber.rx.bgColor])
            .bind({ UIColor($0.error          ) }, to: [mobileNumber.rx.errorColor])
            .bind({ UIColor($0.primary        ) }, to: [signInButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark       ) }, to: [signInButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primary        ) }, to: [signUpButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark       ) }, to: [signUpLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [rememberIDSwitch.rx.onTintColor])
            .bind({ UIColor($0.greyLight      ) }, to: [rememberIDSwitch.rx.offTintColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [rememberIDLabel.rx.textColor])
            .disposed(by: rx.disposeBag)

        guard let backButton = backButton else { return }

        themeService.rx
            .bind({ UIColor($0.primary        ) }, to: [backButton.rx.backgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        guard let viewModel = viewModel else { return }

        // MARK: Output Bindings
        // viewModel.outputs.rememberMe.bind(to: rememberIDSwitch.rx.isOn).disposed(by: rx.disposeBag)
        viewModel.outputs.mobileNumber.bind(to: mobileNumber.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.isFirstResponder.bind(to: mobileNumber.rx.isFirstResponder).disposed(by: rx.disposeBag)

        viewModel.outputs.flag
            .map({ UIImage(named: $0, in: .yapPakistan) })
            .bind(to: mobileNumber.leftIcon.rx.image(for: .normal))
            .disposed(by: rx.disposeBag)

        viewModel.outputs.progress
            .bind(to: rx.loader)
            .disposed(by: rx.disposeBag)

        let validation = viewModel.outputs.validationResult.share()
        validation.map{ $0 == .valid }
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        validation
            .bind(to: mobileNumber.rx.validation)
            .disposed(by: rx.disposeBag)

        // MARK: Inputs Bindings
        rememberIDSwitch.rx.isOn.bind(to: viewModel.inputs.rememberMeObserver).disposed(by: rx.disposeBag)
        mobileNumber.rx.text.bind(to: viewModel.inputs.mobileNumberObserver).disposed(by: rx.disposeBag)
        mobileNumber.rx.isFirstResponder.bind(to: viewModel.inputs.isFirstResponderObserver).disposed(by: rx.disposeBag)

        signInButton.rx.tap
            .bind(to: viewModel.inputs.signInObserver)
            .disposed(by: rx.disposeBag)
        signUpButton.rx.tap
            .bind(to: viewModel.inputs.signUpObserver)
            .disposed(by: rx.disposeBag)
        backButton?.rx.tap
            .map{ .cancel }.bind(to: viewModel.inputs.backObserver)
            .disposed(by: rx.disposeBag)

        // MARK: Other Bindings
        view.rx.tapGesture()
            .map({ _ in true })
            .bind(to: view.rx.endEditting)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        topImage.alignEdgesWithSuperview([.top, .left, .right])

        logo.alignEdge(.bottom, withView: topImage, constant: 3)
            .centerHorizontallyInSuperview()

        headingLabel.toBottomOf(logo, constant: 32)
            .alignEdgesWithSuperview([.left, .right], constant: 19)
            .centerHorizontallyInSuperview()

        mobileNumber.toBottomOf(headingLabel, constant: 32)
            .alignEdgesWithSuperview([.right, .left], constant: 19)
            .height(constant: 86)

        stackView.toBottomOf(mobileNumber, constant: 10)
            .centerHorizontallyInSuperview()

        signInButton.toBottomOf(stackView, .greaterThanOrEqualTo, constant: 15)
            .height(constant: 52)
            .width(constant: 192)
            .centerHorizontallyInSuperview()

        signUpLabel.alignEdgesWithSuperview([.top, .bottom, .left])

        signUpButton.alignEdgesWithSuperview([.top, .bottom, .right])
            .toRightOf(signUpLabel, constant: 5)

        signUpContainer.alignEdgeWithSuperviewSafeArea(.bottom, constant: 30)
            .height(constant: 24)
            .centerHorizontallyInSuperview()
            .toBottomOf(signInButton, constant: 20, assignTo: &signInButtonBottomConstraint)
    }
 }

// MARK: Keyboard Notifications
extension LoginViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let signUpLableOrigin = view.bounds.size.height - signUpContainer.frame.origin.y
            signInButtonBottomConstraint.constant = ((keyboardHeight - signUpLableOrigin) + 20)
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        signInButtonBottomConstraint.constant = 20
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
 }

// MARK: - other private tasks
fileprivate extension LoginViewController {
    func removeForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
 }

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        viewModel.inputs.textWillChangeObserver.onNext((string, range, textField.text))
        return viewModel.outputs.shouldChange
    }
 }
