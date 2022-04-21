//
//  PersonalDetailsViewController.swift
//  YAPPakistan
//
//  Created by Awais on 06/04/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxTheme

class PersonalDetailsViewController: UIViewController {

    // MARK: - Init
    init(viewModel: PersonalDetailsViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Views
    
//    private lazy var name: MoreBankDetailsInfoView = {
//        let view = MoreBankDetailsInfoView()
//        view.titleText = "screen_more_bank_details_display_text_name".localized
//        view.detailText = "Hello From World"
//        view.canCopy = false
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    
    private lazy var fullNameField = UIFactory.makeStaticTextField(title: "screen_personal_details_display_text_full_name".localized, titleColor: UIColor(themeService.attrs.greyDark), titleFont: .micro, textColor: UIColor(themeService.attrs.primaryDark), textFont: .regular, isEditable: false)

    private lazy var phoneNumberField : StaticAppTextField = {
        let field = StaticAppTextField()
        field.titleLabel.text = "screen_personal_details_display_text_phone_number".localized
        field.isEditable = true
        field.titleColor = UIColor(themeService.attrs.greyDark)
        field.textColor = UIColor(themeService.attrs.primaryDark)
        return field
    }()
    
    private lazy var emailField : StaticAppTextField = {
        let field = StaticAppTextField()
        field.titleLabel.text = "screen_personal_details_display_text_email".localized
        field.isEditable = true
        field.titleColor = UIColor(themeService.attrs.greyDark)
        field.textColor = UIColor(themeService.attrs.primaryDark)
        return field
    }()
    
    private lazy var addressField : StaticAppTextField = {
        let field = StaticAppTextField()
        field.titleLabel.text = "screen_personal_details_display_text_address".localized
        field.isEditable = true
        field.titleColor = UIColor(themeService.attrs.greyDark)
        field.textColor = UIColor(themeService.attrs.primaryDark)
        return field
    }()
    
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
  
    lazy var eidView = KYCDocumentView()
    lazy var fieldsStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [fullNameField, phoneNumberField, emailField, addressField])
    lazy var contentStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 40, arrangedSubviews: [fieldsStackView, eidView, UIView()])

    // MARK: - Properties
    let viewModel: PersonalDetailsViewModelType
    private var themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        viewModel.inputs.viewWillAppearObserver.onNext(())
    }

    override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
    }
}

// MARK: - Setup
fileprivate extension PersonalDetailsViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
        //addBackButton(.backEmpty)
    }
    
    func setupTheme() {
        
    }

    func setupViews() {
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        view.backgroundColor = .white
        view.addSubview(contentStackView)
    }

    func setupConstraints() {
        contentStackView.alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom], constants: [25, 20, 25, 0])
    }
}

// MARK: - Bind
fileprivate extension PersonalDetailsViewController {
    func bind() {
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: rx.title).disposed(by: disposeBag)

        viewModel.outputs.fullName.bind(to: fullNameField.rx.text).disposed(by: disposeBag)

        viewModel.outputs.phone.bind(to: phoneNumberField.rx.text).disposed(by: disposeBag)
        phoneNumberField.rx.editObserver.bind(to: viewModel.inputs.editPhoneTapObserver).disposed(by: disposeBag)

        viewModel.outputs.email.bind(to: emailField.rx.text).disposed(by: disposeBag)
        emailField.rx.editObserver.bind(to: viewModel.inputs.editEmailTapObserver).disposed(by: disposeBag)

        viewModel.outputs.address.bind(to: addressField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.address.startWith(nil).map { $0 == nil }.bind(to: addressField.rx.isHidden).disposed(by: disposeBag)
        addressField.rx.editObserver.bind(to: viewModel.inputs.editAddressTapObserver).disposed(by: disposeBag)

//        let status = Observable.combineLatest(SessionManager.current.currentAccount.map{ $0?.parnterBankStatus ?? .signUpPending }, viewModel.outputs.emiratesIDStatus)
//
//        status.subscribe(onNext: { [weak self] accountStatus, emiratesIDStatus in
//            guard let `self` = self else { return }
//            self.eidView.isHidden = emiratesIDStatus == .none
//            self.eidView.title = "screen_personal_details_display_text_emirates_id".localized
//            self.eidView.validation = emiratesIDStatus.isExpired ? .invalid : .valid
//            self.eidView.viewType = .detailsOnly
//
//            self.eidView.details = emiratesIDStatus == .valid ? accountStatus == .activated ? "screen_personal_details_display_text_emirates_id_details_update".localized: "screen_personal_details_display_text_emirates_id_details".localized : emiratesIDStatus == .notSet ? "screen_personal_details_display_text_required_emirates_id_details".localized : emiratesIDStatus == .expired ? "screen_personal_details_display_text_expired_emirates_id_details".localized : ""
//
//            self.eidView.icon = UIImage(named: "iconDummy", in: moreBundle, compatibleWith: nil)?.asTemplate
//            self.eidView.subTitleColors = SessionManager.current.currentAccountType == .b2cAccount ? .greyDark : .white
//
//        }).disposed(by: disposeBag)

//        eidView.rx.tap.withLatestFrom(status).filter { $0.1.isExpired || $0.0 == .activated }.subscribe(onNext: { [weak self] in
//            if SessionManager.current.currentProfile?.restrictions.contains(.otpBlocked) ?? false && $0.0 == .activated {
//                UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
//            } else {
//                self?.viewModel.inputs.updateEmiratesIDTapObserver.onNext(())
//            }
//        }).disposed(by: disposeBag)

        bindError()
        bindActivityIndicator()
    }

    func bindError() {
        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }).disposed(by: disposeBag)

        viewModel.outputs.showBlockedOTPError.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error)
        }).disposed(by: disposeBag)
    }

    func bindActivityIndicator() {
//        viewModel.outputs.isRunning.subscribe(onNext: { isRunning in
//            _ = isRunning ? YAPProgressHud.showProgressHud() : YAPProgressHud.hideProgressHud()
//        }).disposed(by: disposeBag)
    }
}
