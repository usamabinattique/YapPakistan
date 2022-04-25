//
//  ChangeEmailAddressViewController.swift
//  YAPPakistan
//
//  Created by Awais on 12/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class ChangeEmailAddressViewController: KeyboardAvoidingViewController {
    
    //MARK: Properties
    private var themeService: ThemeService<AppTheme>
    
    // MARK: - Init
    init(viewModel: ChangeEmailAddressViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    private lazy var headingLabel: UILabel = UIFactory.makePaddingLabel(font: .title2, alignment: .center)  //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title2, alignment: .center)
    private lazy var descriptionLabel: UILabel = UIFactory.makePaddingLabel(font: .small, alignment: .center, numberOfLines: 0)  //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, numberOfLines: 0)
    private lazy var nextButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_next".localized, isEnable: false)
    
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
    
    
    lazy var emailTextfield: AppTextField = {
        let textfield = AppTextField()
        textfield.keyboardType = .emailAddress
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .next
        textfield.placeholder =  "screen_change_email_placeholder_email_address".localized
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    lazy var confirmEmailTextfield: AppTextField = {
        let textfield = AppTextField()
        textfield.keyboardType = .emailAddress
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .done
        textfield.placeholder =  "screen_change_email_placeholder_confirm_email_address".localized
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    // MARK: - Properties
    let viewModel: ChangeEmailAddressViewModelType
//    var nextButtonBottomConstraint: NSLayoutConstraint!
    let disposeBag: DisposeBag
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //title = "Edit Email Address"  //SessionManager.current.currentAccountType == .b2cAccount ? nil : "Edit email address"
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.screenType != .iPhone5 {
//            registerForKeyboardNotifications()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        removeForKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
    }
}

// MARK: - Setup
fileprivate extension ChangeEmailAddressViewController {
    func setup() {
        //addBackButton(.closeEmpty)
        setupViews()
        setupTheme()
        setupConstraints()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary        ) }, to: [nextButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark       ) }, to: [nextButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
    }
    
    func setupViews() {
        
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        
        
        view.backgroundColor = .white
        view.addSubview(headingLabel)
        view.addSubview(emailTextfield)
        view.addSubview(confirmEmailTextfield)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
    }
    
    func setupConstraints() {
        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, .lessThanOrEqualTo, constant: 52)
            .alignEdgeWithSuperviewSafeArea(.top, .greaterThanOrEqualTo, constant: 15)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        emailTextfield
            .toBottomOf(headingLabel, constant: 45)
            .height(constant: 72)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        confirmEmailTextfield
            .toBottomOf(emailTextfield, .lessThanOrEqualTo, constant: 25)
            .toBottomOf(emailTextfield, .greaterThanOrEqualTo, constant: 10)
            .height(constant: 72)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        nextButton
            .toBottomOf(confirmEmailTextfield, .greaterThanOrEqualTo, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 192)
            .height(constant: 52)
        
        descriptionLabel
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(nextButton, .lessThanOrEqualTo, constant: 20)
            .toBottomOf(nextButton, .greaterThanOrEqualTo, constant: 10)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 20)
    }
}

// MARK: - Bind
fileprivate extension ChangeEmailAddressViewController {
    func bind() {
        
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.emailTextFieldTitle.bind(to: emailTextfield.rx.titleText).disposed(by: disposeBag)
        viewModel.outputs.confirmEmailTextFieldTitle.bind(to: confirmEmailTextfield.rx.titleText).disposed(by: disposeBag)
        viewModel.outputs.descriptionHeading.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.nextButtonTitle.bind(to: nextButton.rx.title(for: .normal)).disposed(by: disposeBag)
        
        viewModel.outputs.emailValidation.subscribe(onNext: { valuee in
            print("Email Validation: \(valuee)")
        }).disposed(by: disposeBag)
        
        viewModel.outputs.emailValidation.bind(to: emailTextfield.rx.validationState).disposed(by: disposeBag)
        emailTextfield.rx.text.unwrap().bind(to: viewModel.inputs.emailTextFieldObserver).disposed(by: disposeBag)
        
        confirmEmailTextfield.rx.text.unwrap().bind(to: viewModel.inputs.confirmEmailTextFieldObserver).disposed(by: disposeBag)
        
        viewModel.outputs.confirmEmailValidation.bind(to: confirmEmailTextfield.rx.validationState).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: confirmEmailTextfield.rx.errorText).disposed(by: disposeBag)
        
        viewModel.outputs.activateAction.subscribe(onNext: { isOK in
            print("Actiavte button: \(isOK)")
        }).disposed(by: disposeBag)
        
        viewModel.outputs.activateAction.bind(to: nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: disposeBag)
        
        viewModel.outputs.loading.subscribe(onNext: { flage in
            switch flage { case true: YAPProgressHud.showProgressHud()
            case false: YAPProgressHud.hideProgressHud() }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
        
        emailTextfield.rx.controlEvent([.editingDidEndOnExit]).subscribe { [weak self] _ in
            _ = self?.confirmEmailTextfield.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        confirmEmailTextfield.rx.controlEvent([.editingDidEndOnExit]).withLatestFrom(viewModel.outputs.activateAction).filter{ $0 }.subscribe { [weak self] _ in
            self?.viewModel.inputs.nextObserver.onNext(())
        }.disposed(by: disposeBag)
    }
}
