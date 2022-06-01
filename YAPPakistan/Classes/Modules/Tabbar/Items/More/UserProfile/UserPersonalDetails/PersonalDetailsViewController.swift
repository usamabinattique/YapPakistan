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
    
    private lazy var fullNameField = UIFactory.makeStaticTextField(title: "screen_personal_details_display_text_full_name".localized, titleColor: UIColor(themeService.attrs.greyDark), titleFont: .micro, textColor: UIColor(themeService.attrs.primaryDark), textFont: .regular, isEditable: false)

    private lazy var phoneNumberField : StaticAppTextField = {
        let field = StaticAppTextField()
        field.titleLabel.text = "screen_personal_details_display_text_phone_number".localized
        field.isEditable = false
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
        field.isEditable = false
        field.titleColor = UIColor(themeService.attrs.greyDark)
        field.textColor = UIColor(themeService.attrs.primaryDark)
        return field
    }()
    
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
  
//    lazy var CNICView = KYCDocumentView()
    private lazy var CNICView: KYCDocumentView = {
        let view = KYCDocumentView()
        view.viewType = .detailsOnly
        view.icon = UIImage(named: "kyc-user", in: .yapPakistan)
        return view
    }()
    lazy var fieldsStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [fullNameField, phoneNumberField, emailField, addressField])
    lazy var contentStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 40, arrangedSubviews: [fieldsStackView, CNICView, UIView()])

    // MARK: - Properties
    let viewModel: PersonalDetailsViewModelType
    private var themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        viewModel.inputs.refreshObserver.onNext(())
    }

    override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
    }
}

extension PersonalDetailsViewController: ViewDesignable {
    func setupSubViews() {
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        view.backgroundColor = .white
        view.addSubview(contentStackView)
    }
    
    func setupConstraints() {
        contentStackView.alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom], constants: [25, 20, 25, 0])
    }
    
    func setupBindings() {
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: rx.title).disposed(by: disposeBag)

        viewModel.outputs.fullName.bind(to: fullNameField.rx.text).disposed(by: disposeBag)

        viewModel.outputs.phone.bind(to: phoneNumberField.rx.text).disposed(by: disposeBag)
        phoneNumberField.rx.editObserver.bind(to: viewModel.inputs.editPhoneTapObserver).disposed(by: disposeBag)

        viewModel.outputs.email.bind(to: emailField.rx.text).disposed(by: disposeBag)
        emailField.rx.editObserver.bind(to: viewModel.inputs.editEmailTapObserver).disposed(by: disposeBag)

        viewModel.outputs.address.bind(to: addressField.rx.text).disposed(by: disposeBag)
        
        addressField.rx.editObserver.bind(to: viewModel.inputs.editAddressTapObserver).disposed(by: disposeBag)
        
        viewModel.outputs.isValidCnic
            .subscribe(onNext: { isCnincExpired in
                self.CNICView.validation = isCnincExpired ? .invalid : .valid
                self.CNICView.title = "screen_personal_details_display_text_cnic_id".localized
                self.CNICView.details = isCnincExpired ? "screen_personal_details_display_text_expired_cnic_id_details".localized : "screen_personal_details_display_text_cnic_id_details".localized
            })
            .disposed(by: disposeBag)

        CNICView.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.viewModel.inputs.cardTapObserver.onNext(())
            })
            .disposed(by: disposeBag)

        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }).disposed(by: disposeBag)

        viewModel.outputs.showBlockedOTPError.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error)
        }).disposed(by: disposeBag)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.primary) }, to: CNICView.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: CNICView.rx.titleColor)
            .bind({ UIColor($0.greyDark) }, to: CNICView.rx.detailsColor)
            .disposed(by: disposeBag)
    }
}
