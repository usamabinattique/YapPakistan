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


//TODO Login screen Needs to be refacrtor.

class LoginViewController: UIViewController {
    
    //var viewModel: LoginViewModelType!
    
    fileprivate lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.image = UIImage(named: "icon_app_logo", in:.yapPakistan)
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    fileprivate lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .large)
        label.text =  "screen_sign_in_display_text_heading_text".localized
        //label.textColor = UIColor.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameTextField: AppRoundedTextField = {
        let textfield = AppRoundedTextField()
        textfield.placeholder =  "screen_sign_in_input_text_email_hint".localized
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = UITextAutocapitalizationType.none
        textfield.autocorrectionType = UITextAutocorrectionType.no
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.returnKeyType = .done
        textfield.clearButtonMode = .whileEditing
        textfield.errorTextColor = .red    //.error
        //textfield.placeholderColor = .blue //.greyDark
        return textfield
    }()
    
    fileprivate lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "image_backgound")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    fileprivate lazy var rememberId: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .small)
        label.text =  "screen_sign_in_display_text_remember_id_text".localized
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var rememberIdSwitch: UIAppSwitch = UIAppSwitchFactory.createUIAppSwitch(isOn: true, onImage: UIImage(named: "icon_check_primary_dark", in:.yapPakistan)?.asTemplate)
    
    fileprivate lazy var signInButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.setTitle("screen_sign_in_button_sign_in".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    fileprivate lazy var signUpLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.appFont(forTextStyle: .regular)
        label.setTitleColor(UIColor.darkGray /*.appColor(ofType: .greyDark)*/, for: .normal)
        let text = "screen_sign_in_display_text_sign_up".localized()
        let signUp = "Sign up"
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.foregroundColor, value: UIColor.darkGray /*.appColor(ofType: .greyDark)*/, range: NSRange(location: 0, length: text.count))
        attributed.addAttributes([.foregroundColor: UIColor.blue /*.primary*/, .underlineStyle: NSUnderlineStyle.single.rawValue], range: (text as NSString).range(of: signUp))
        
        label.setAttributedTitle(attributed, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var signInButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bind(viewModel: viewModel)
        setupSubViews()
        setupConstraints()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if UIScreen.screenType != .iPhone5 {
            registerForKeyboardNotifications()
        //}
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeForKeyboardNotifications()
    }
    
    override func onTapBackButton() {
        //viewModel.inputs.onSignUp.onNext(())
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
}

extension LoginViewController {
    
    fileprivate func setupSubViews() {
        view.backgroundColor = .white
        //if let count = navigationController?.viewControllers.count, count > 1 { addBackButton() }
        view.addSubview(backgroundImage)
        view.addSubview(logo)
        view.addSubview(headingLabel)
        view.addSubview(usernameTextField)
        view.addSubview(stackView)
        stackView.addArrangedSubview(rememberId)
        stackView.addArrangedSubview(rememberIdSwitch)
        view.addSubview(signInButton)
        view.addSubview(signUpLabel)
    }
    
    fileprivate func setupConstraints() {
        let logoConstraints = [
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let headingConstraints = [
            headingLabel.topAnchor.constraint(lessThanOrEqualTo: logo.bottomAnchor, constant: 32.6),
            headingLabel.topAnchor.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 15),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: headingLabel.trailingAnchor),
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        usernameTextField
            .toBottomOf(headingLabel, .lessThanOrEqualTo, constant: 53)
            .toBottomOf(headingLabel, .greaterThanOrEqualTo, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constants: [19, 19])
            .height(constant: 86)
        
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let backgroundImageConstraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 160),
            view.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor)
            
        ]
        
        signInButtonBottomConstraint = signUpLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20)
        
        let signInButtonContraints = [
            signInButtonBottomConstraint!,
            signInButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 15),
            signInButton.heightAnchor.constraint(equalToConstant: 52),
            signInButton.widthAnchor.constraint(equalToConstant: 192),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let signInLabelContraints = [
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 30),
            signUpLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width),
            signUpLabel.heightAnchor.constraint(equalToConstant: 24),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(logoConstraints +
            headingConstraints +
            stackViewConstraints +
            signInButtonContraints +
            signInLabelContraints +
            backgroundImageConstraints
        )
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
            let signUpLableOrigin = view.bounds.size.height - signUpLabel.frame.origin.y
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
    /*
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
        viewModel.outputs.username.bind(to: usernameTextField.rx.text).disposed(by: rx.disposeBag)
        
        usernameTextField.rx.text.orEmpty.bind(to: viewModel.inputs.usernameObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.activateSignInButton.bind(to: signInButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.validation.bind(to: usernameTextField.rx.validation).disposed(by: rx.disposeBag)
        
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
        signUpLabel.rx.tap.bind(to: viewModel.inputs.onSignUp).disposed(by: rx.disposeBag)
     
        
    }
    
    private func bindSwitches(viewModel: LoginViewModelType) {
        rememberIdSwitch.rx.isOn.skip(1).bind(to: viewModel.inputs.rememberIdObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.rememberId.bind(to: rememberIdSwitch.rx.isOn).disposed(by: rx.disposeBag)
    }
    
    
    private func bindError(viewModel: LoginViewModelType) {
        
        viewModel.outputs.error.map{ _ in return AppRoundedTextFieldValidation.invalid }.bind(to: usernameTextField.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: usernameTextField.rx.errorText).disposed(by: rx.disposeBag)
    } */
}
