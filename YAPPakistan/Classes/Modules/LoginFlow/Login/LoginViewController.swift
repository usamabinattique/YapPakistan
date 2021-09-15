//
//  LoginViewController.swift
//  App
//
//  Created by Wajahat Hassan on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme


//TODO Login screen Needs to be refacrtor.

class LoginViewController: UIViewController {
    
    fileprivate lazy var logo = UIFactory.makeImageView(image: UIImage(named: "icon_app_logo", in:.yapPakistan), contentMode: .scaleAspectFit)

    fileprivate lazy var headingLabel = UIFactory.makeLabel(font: .large, alignment: .center, text: "screen_sign_in_display_text_heading_text".localized)
    
    private lazy var mobileNumber = UIFactory.makeAppRoundedTextField(with: .regular, errorFont: .micro, validImage: UIImage(named: "icon_check", in: .yapPakistan), inValidImage: UIImage(named: "icon_invalid", in: .yapPakistan), leftIcon: nil, displaysIcon:true, returnKeyType:.send, autocorrectionType:.no, keyboardType:.asciiCapableNumberPad)
    
    fileprivate lazy var backgroundImage = UIFactory.makeImageView(image: UIImage(named: "image_backgound", in: .yapPakistan), contentMode: .scaleAspectFit)
    
    private lazy var stackView = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 10)
    
    fileprivate lazy var rememberId = UIFactory.makeLabel(font: .small, text: "screen_sign_in_display_text_remember_id_text".localized)
    
    fileprivate lazy var rememberIdSwitch = UIFactory.makeAppSwitch(isOn: true, onImage: UIImage(named: "icon_check_primary_dark", in:.yapPakistan)?.asTemplate)
    
    fileprivate lazy var signInButton = UIFactory.makeAppRoundedButton(with: .regular, title: "screen_sign_in_button_sign_in".localized)
    
    fileprivate lazy var signUpButton = UIFactory.makeButton(with: .regular, title: "screen_sign_in_display_text_sign_up".localized)
    
    fileprivate var signInButtonBottomConstraint: NSLayoutConstraint!
    fileprivate var viewModel: LoginViewModelType!
    fileprivate var themeService:ThemeService<AppTheme>!
    
    init(viewModel: LoginViewModelType, themeService:ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(viewModel: viewModel)
        setupSubViews()
        setupTheme()
        setupConstraints()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.screenType != .iPhone5 {
            registerForKeyboardNotifications()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeForKeyboardNotifications()
    }
    
    override func onTapBackButton() {
        viewModel.inputs.onSignUp.onNext(())
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
}

fileprivate extension LoginViewController {
    
    func setupSubViews() {
        //if let count = navigationController?.viewControllers.count, count > 1 { addBackButton() }
        view.addSubview(backgroundImage)
        view.addSubview(logo)
        view.addSubview(headingLabel)
        view.addSubview(mobileNumber)
        view.addSubview(stackView)
        stackView.addArrangedSubview(rememberId)
        stackView.addArrangedSubview(rememberIdSwitch)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor  )}, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark      )}, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary          )}, to: [mobileNumber.rx.primaryColor])
            .bind({ UIColor($0.primaryDark      )}, to: [mobileNumber.rx.secondaryColor])
            .bind({ UIColor($0.greyLight        )}, to: [mobileNumber.rx.bgColor])
            .bind({ UIColor($0.error            )}, to: [mobileNumber.rx.errorColor])
            .bind({ UIColor($0.primary          )}, to: [signInButton.rx.backgroundColor])
            .bind({ UIColor($0.greyLight        )}, to: [signUpButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        let constraints = [
            
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //backgroundImage.heightAnchor.constraint(equalToConstant: 160),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            logo.bottomAnchor.constraint(equalTo: backgroundImage.bottomAnchor, constant: -5),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            headingLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 32.6),
            //headingLabel.topAnchor.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 15),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mobileNumber.topAnchor.constraint(lessThanOrEqualTo: headingLabel.topAnchor, constant: 53),
            mobileNumber.topAnchor.constraint(greaterThanOrEqualTo: headingLabel.topAnchor, constant: 10),
            mobileNumber.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            mobileNumber.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            mobileNumber.heightAnchor.constraint(equalToConstant: 86),
            
            stackView.topAnchor.constraint(equalTo: mobileNumber.bottomAnchor, constant: 10),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signInButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 15),
            signInButton.heightAnchor.constraint(equalToConstant: 52),
            signInButton.widthAnchor.constraint(equalToConstant: 192),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            signUpButton.widthAnchor.constraint(equalToConstant: view.bounds.size.width),
            signUpButton.heightAnchor.constraint(equalToConstant: 24),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Constraints with class level reference
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20)
        ]
        
        signInButtonBottomConstraint = constraints[constraints.count - 1]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension LoginViewController {
    
    func removeForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let signUpLableOrigin = view.bounds.size.height - signUpButton.frame.origin.y
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

extension LoginViewController {
    
    fileprivate func bind(viewModel: LoginViewModelType?) {
        guard let `viewModel` = viewModel else { return }
        bindInputTextField(viewModel: viewModel)
        bindLoader(viewModel: viewModel)
        bindActions(viewModel: viewModel)
        bindSwitches(viewModel: viewModel)
        bindError(viewModel: viewModel)
        bindEditing(viewModel: viewModel)
    }
    
    fileprivate func bindInputTextField(viewModel: LoginViewModelType) {
        //viewModel.outputs.username.bind(to: usernameTextField.rx.text).disposed(by: rx.disposeBag)
        
        //usernameTextField.rx.text.orEmpty.bind(to: viewModel.inputs.usernameObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.activateSignInButton.bind(to: signInButton.rx.isEnabled).disposed(by: rx.disposeBag)
        //viewModel.outputs.validation.bind(to: usernameTextField.rx.validation).disposed(by: rx.disposeBag)
        
    }
    
    private func bindEditing(viewModel: LoginViewModelType) {
        
        viewModel.outputs.endEditing.subscribe(onNext: { [unowned self] _ in
            self.view.endEditing(true)
        }).disposed(by: rx.disposeBag)
    }
    
    private func bindLoader(viewModel: LoginViewModelType) {
        
        viewModel.outputs.loading.subscribe(onNext: { flage in
            switch flage {
            case true:
                YAPProgressHud.showProgressHud()
            case false:
                YAPProgressHud.hideProgressHud()
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    private func bindActions(viewModel: LoginViewModelType) {
        signInButton.rx.tap.do(onNext:{ [weak self] _ in self?.view.endEditing(true) }).bind(to: viewModel.inputs.onSignIn).disposed(by: rx.disposeBag)
        signUpButton.rx.tap.bind(to: viewModel.inputs.onSignUp).disposed(by: rx.disposeBag)
     
        
    }
    
    private func bindSwitches(viewModel: LoginViewModelType) {
        rememberIdSwitch.rx.isOn.skip(1).bind(to: viewModel.inputs.rememberIdObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.rememberId.bind(to: rememberIdSwitch.rx.isOn).disposed(by: rx.disposeBag)
    }
    
    
    private func bindError(viewModel: LoginViewModelType) {
        
        //viewModel.outputs.error.map{ _ in return AppRoundedTextFieldValidation.invalid }.bind(to: //usernameTextField.rx.validation).disposed(by: rx.disposeBag)
        //viewModel.outputs.error.bind(to: usernameTextField.rx.errorText).disposed(by: rx.disposeBag)
    }
}
