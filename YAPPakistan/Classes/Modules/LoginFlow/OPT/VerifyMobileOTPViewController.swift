//
//  VerifyMobileOTPViewController.swift
//  YAPKit
//
//  Created by Hussaan S on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

public class VerifyMobileOTPViewController: UIViewController {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = .title2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = .regular
        label.textAlignment = .center
        label.numberOfLines = 2
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
        label.textAlignment = .center
        label.text = "5:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = .large
        button.setTitle( "screen_device_registration_otp_button_resend_otp".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sendButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title =  "screen_device_registration_otp_button_send".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var backButton:UIButton!
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 10)
    
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: VerifyMobileOTPViewModelType!
    private let disposeBag = DisposeBag()
    private var sendButtonBottomConstraint: NSLayoutConstraint!
    
    public init(themeService: ThemeService<AppTheme>, viewModel: VerifyMobileOTPViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.generateOTPObserver.onNext(())
        if UIScreen.screenType != .iPhone5 {
            registerForKeyboardNotifications()
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(false)
        removeForKeyboardNotifications()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(true)
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
}

// MARK: View setup

extension VerifyMobileOTPViewController {
    func setupViews() {
        backButton = addBackButton(of: .backEmpty)
        view.addSubview(stackView)
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(codeTextField)
        view.addSubview(resendButton)
        view.addSubview(timerLabel)
        view.addSubview(sendButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ headingLabel.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ subHeadingLabel.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ timerLabel.rx.textColor ])
            .bind({ UIColor($0.primary) }, to: [ resendButton.rx.titleColor(for: .normal) ])
            .bind({ UIColor($0.primary) }, to: [ sendButton.rx.enabledBackgroundColor ])
            .bind({ UIColor($0.greyDark) }, to: [ sendButton.rx.disabledBackgroundColor ])
            .disposed(by: rx.disposeBag)
        
        guard let backButton = backButton else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        stackView
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right], constants: [25, 18, 25])
        
        logoImageView
            .height(constant: 60)
            .width(constant: 60)
        
        subHeadingLabel
            .toBottomOf(stackView, constant: 10)
            .alignEdgeWithSuperview(.left, constant: 25)
            .centerHorizontallyInSuperview()
        
        codeTextField
            .toBottomOf(subHeadingLabel, .lessThanOrEqualTo, constant: 22)
            .toBottomOf(subHeadingLabel, .greaterThanOrEqualTo, constant: 12)
            .height(constant: 64)
            .centerHorizontallyInSuperview()
        
        timerLabel
            .centerHorizontallyInSuperview()
            .toBottomOf(codeTextField, .lessThanOrEqualTo, constant: 30)
            .toBottomOf(codeTextField, .greaterThanOrEqualTo, constant: 10)
        
        resendButton
            .centerHorizontallyInSuperview()
            .toBottomOf(timerLabel, .lessThanOrEqualTo, constant: 13)
            .toBottomOf(timerLabel, .greaterThanOrEqualTo, constant: 10)
        
        sendButton
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)
            .toBottomOf(resendButton, .greaterThanOrEqualTo, constant: 12)
        
        sendButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12)
        sendButtonBottomConstraint.isActive = true
        
    }
    
//    func render() {
////        logoImageView.roundView()
//    }
}

extension VerifyMobileOTPViewController {
    
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
            sendButtonBottomConstraint.constant = keyboardHeight + 12
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        sendButtonBottomConstraint.constant = 12
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: Binding

private extension VerifyMobileOTPViewController {
    func bindViews() {
        
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        
        bindOTPGenerationError()
        codeTextField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        viewModel.outputs.timerText.bind(to: timerLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.subheading.bind(to: subHeadingLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.heading.bind(to: headingLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.resendActive.bind(to: resendButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.resendActive.map { $0 ? 1.0 : 0.3 }.bind(to: resendButton.rx.alpha).disposed(by: disposeBag)
        viewModel.outputs.valid.bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
        resendButton.rx.tap.bind(to: viewModel.inputs.resendOTPObserver).disposed(by: disposeBag)
        viewModel.outputs.imageFlag.map { !$0 }.bind(to: logoImageView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.imageFlag.subscribe(onNext: {[weak self] flag in
            if flag == true {
                self?.headingLabel.topAnchor.constraint(equalTo: (self?.view.safeAreaLayoutGuide.topAnchor)!, constant: 52).isActive = true
            } else {
                self?.headingLabel.topAnchor.constraint(equalTo: (self?.logoImageView.bottomAnchor)!, constant: 30).isActive = true
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.showAlert.subscribe(onNext: { [weak self] in
            self?.showAlert(title: "", message: $0, defaultButtonTitle: "Ok", secondayButtonTitle: nil, defaultButtonHandler: { [weak self] _ in
                _ = self?.codeTextField.becomeFirstResponder()
            }, secondaryButtonHandler: nil, completion: nil)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.outputs.image, viewModel.outputs.heading)
            .map { [unowned self] image, heading -> UIImage? in
                if image != nil { return image! } else if heading != nil {
                    self.logoImageView.layoutIfNeeded()
                    // return UIImage.imageSnap(text: heading!.string, color: .appColor(ofType: .greyLight),
                    //                          textColor: .appColor(ofType: .greyDark), bounds:
                    //                             self.logoImageView.bounds, contentMode: self.logoImageView.contentMode)
                    return UIImage()
                } else { return nil }
        }.bind(to: logoImageView.rx.image)
        .disposed(by: disposeBag)
        
        //viewModel.outputs.backImage
        //.subscribe(onNext: { [unowned self] image in
        //    self.addBackButton(of: image)
        //})
        //.disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        viewModel.outputs.error.map{ _ in }.bind(to: codeTextField.rx.clear).disposed(by: disposeBag)
        sendButton.rx.tap.do(onNext: { [weak self] in self?.view.endEditing(true) }).bind(to: viewModel.inputs.sendObserver).disposed(by: disposeBag)
        resendButton.rx.tap.do(onNext: { [weak self] in self?.view.endEditing(true) }).bind(to: viewModel.inputs.generateOTPObserver).disposed(by: disposeBag)
        
        viewModel.outputs.editing.subscribe(onNext: { [weak self] in
            if $0 { _ = self?.codeTextField.becomeFirstResponder() } else { self?.view.endEditing(true) }
        }).disposed(by: disposeBag)
    }
    
    private func bindOTPGenerationError() {
        let retry = viewModel.outputs.generateOTPError.flatMap {  message -> Observable<Bool> in
            return Observable<Bool>.create { [weak self] observer in
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title:  "Retry".localized, style: .default, handler: { _ in
//                    observer.onNext(true)
//                }))
                alert.addAction(UIAlertAction(title:  "Ok".localized, style: .cancel, handler: { _ in
//                    observer.onNext(false)
                }))
                self?.present(alert, animated: true, completion: nil)
                return Disposables.create()
            }
            }.share()
        
        retry.filter { $0 }.map { _ in () }.bind(to: viewModel.inputs.generateOTPObserver).disposed(by: disposeBag)
        retry.filter { !$0 }.map { _ in () }.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
    }

}

// MARK: Text field delegate

extension VerifyMobileOTPViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == codeTextField {
            return range.location < codeTextField.numberOfTextFields
        }
        return true
    }
}
