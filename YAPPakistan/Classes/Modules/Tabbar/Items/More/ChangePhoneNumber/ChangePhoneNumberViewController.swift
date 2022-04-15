//
//  ChangePhoneNumberViewController.swift
//  YAPPakistan
//
//  Created by Awais on 13/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import PhoneNumberKit
import RxTheme

class ChangePhoneNumberViewController: UIViewController {

    // MARK: - Init
    init(viewModel: ChangePhoneNumberViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Views
    private lazy var headingLabel: UILabel = UIFactory.makePaddingLabel(font: .title2, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title2, alignment: .center)
    private lazy var nextButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_next".localized, isEnable: false)

    lazy var phoneNumberTextfield: PhoneNumberView = {
        let textfield = PhoneNumberView()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()

    // MARK: - Properties
    private var themeService: ThemeService<AppTheme>
    let viewModel: ChangePhoneNumberViewModelType
    let disposeBag: DisposeBag
    var nextButtonBottomConstraint: NSLayoutConstraint!
    private let phoneNumberKit = PhoneNumberKit()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit phone number" //SessionManager.current.currentAccountType == .b2cAccount ? nil : "Edit phone number"
        setup()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.screenType != .iPhone5 {
            registerForKeyboardNotifications()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeForKeyboardNotifications()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
    }
}

// MARK: - Setup
fileprivate extension ChangePhoneNumberViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
        //addBackButton(.closeEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [nextButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [nextButton.rx.disabledBackgroundColor])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(headingLabel)
        view.addSubview(phoneNumberTextfield)
        view.addSubview(nextButton)
    }

    func setupConstraints() {

        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 60)

        phoneNumberTextfield
            .toBottomOf(headingLabel, constant: 25)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 60)

        nextButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 10)
        let nextButtonContraints = [
            nextButtonBottomConstraint!,
            nextButton.heightAnchor.constraint(equalToConstant: 52),
            nextButton.widthAnchor.constraint(equalToConstant: 192),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]

        NSLayoutConstraint.activate(nextButtonContraints)
    }
}

// MARK: - Bind
fileprivate extension ChangePhoneNumberViewController {
    func bind() {

        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.nextButtonTitle.bind(to: nextButton.rx.title(for: .normal)).disposed(by: disposeBag)

        viewModel.outputs.text.unwrap().bind(to: phoneNumberTextfield.rx.attributedText).disposed(by: disposeBag)
        phoneNumberTextfield.textField.rx.text.unwrap().bind(to: viewModel.inputs.phoneNumberTextFieldObserver).disposed(by: disposeBag)
        viewModel.outputs.inputValidation.bind(to: phoneNumberTextfield.rx.validationState).disposed(by: disposeBag)

        viewModel.outputs.phoneNumberTextFieldTitle.bind(to: phoneNumberTextfield.rx.titleText).disposed(by: disposeBag)

        viewModel.outputs.countryCode.bind(to: phoneNumberTextfield.rx.countryCode).disposed(by: disposeBag)
        
        viewModel.outputs.activateAction.subscribe(onNext: { [weak self] isActive in
            print(isActive)
        })

        viewModel.outputs.activateAction.bind(to: nextButton.rx.isEnabled).disposed(by: disposeBag)

        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: disposeBag)

        viewModel.outputs.error.bind(to: phoneNumberTextfield.rx.errorText).disposed(by: disposeBag)

        viewModel.outputs.loading.subscribe(onNext: { flage in
            switch flage { case true: YAPProgressHud.showProgressHud()
            case false: YAPProgressHud.hideProgressHud() }
        }).disposed(by: disposeBag)
    }
}

extension ChangePhoneNumberViewController {

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
            nextButtonBottomConstraint.constant = keyboardHeight + 10
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        nextButtonBottomConstraint.constant = 10
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
}
