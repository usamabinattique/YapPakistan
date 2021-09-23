//
//  SystemPermissionViewController.swift
//  App
//
//  Created by Uzair on 18/06/2021.
//

import RxCocoa
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class SystemPermissionViewController: UIViewController {

    // swiftlint:disable force_cast
    let appDelegate = UIApplication.shared.delegate as! PublicAppDelegate
    // swiftlint:enable force_cast
    let viewModel: SystemPermissionViewModelType
    fileprivate var disposeBag = DisposeBag()
    fileprivate var widthConstraint: NSLayoutConstraint?
    fileprivate var permissionType: SystemPermissionType?
    fileprivate var username: String = ""
    
    fileprivate lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .primary
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    fileprivate lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = .title3
        label.textColor = UIColor.appColor(ofType: .black)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    fileprivate lazy var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = .small
        label.textColor = .greyDark
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var termsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .small
        label.textColor = UIColor.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var termsConditionButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_system_permission_text_terms_and_conditions".localized, for: .normal)
        button.titleLabel?.font = .small
        button.setTitleColor(UIColor.appColor(ofType: .primary), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(SystemPermissionViewController.openTermsAndConditions), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var permissionButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var thanksButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_system_permission_text_denied".localized, for: .normal)
        button.setTitleColor(UIColor.appColor(ofType: .primary), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var themeService: ThemeService<AppTheme>!

    init(viewModel: SystemPermissionViewModelType, username: String = "") {
        self.viewModel = viewModel
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(viewModel: viewModel)
        setupSubViews()
        setupConstraints()
    }
    
    @objc private func openTermsAndConditions() {
        let url = URL.init(string: "https://www.yap.com/uploads/EDB-Business-Banking-General-Terms-and-Conditions-Final-22082021.pdf")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension SystemPermissionViewController {
    fileprivate func setupSubViews() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        view.addSubview(icon)
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(termsDescriptionLabel)
        view.addSubview(termsConditionButton)
        view.addSubview(permissionButton)
        view.addSubview(thanksButton)
    }

    fileprivate func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
//            .bind({ UIColor($0.primaryDark) }, to: heading.rx.textColor)
//            .bind({ UIColor($0.greyDark) }, to: subHeading.rx.textColor)
//            .bind({ UIColor($0.backgroundColor) }, to: playerView.rx.backgroundColor)
//            .bind({ UIColor($0.greyDark) }, to: infoLabel.rx.textColor)
//            .bind({ UIColor($0.primary) }, to: completeVerificationButton.rx.backgroundColor)
//            .disposed(by: disposeBag)
    }

    fileprivate func setupConstraints() {
        let iconConstraints = [
            icon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75),
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let headingConstraints = [
            headingLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 47),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: headingLabel.trailingAnchor, constant: 30)
        ]
        
        let subHeadingConstraints = [
            subHeadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20),
            subHeadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: subHeadingLabel.trailingAnchor, constant: 30)
        ]
        
        let termsConditionDescriptionConstraints = [
            termsConditionButton.topAnchor.constraint(equalTo: termsDescriptionLabel.bottomAnchor, constant: 0),
            termsDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsDescriptionLabel.trailingAnchor, constant: 25)
        ]
        
        let termsConditionButtonConstraints = [
            permissionButton.topAnchor.constraint(equalTo: termsConditionButton.bottomAnchor, constant: 31),
            termsConditionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsConditionButton.trailingAnchor, constant: 25)
        ]
        
        let permissionButtonConstraints = [
            widthConstraint!,
            thanksButton.topAnchor.constraint(equalTo: permissionButton.bottomAnchor, constant: 23),
            permissionButton.heightAnchor.constraint(equalToConstant: 52),
            permissionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let thanksButtonContraints = [
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: thanksButton.bottomAnchor, constant: 30),
            thanksButton.widthAnchor.constraint(equalToConstant: view.bounds.size.width),
            thanksButton.heightAnchor.constraint(equalToConstant: 24),
            thanksButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(
            iconConstraints +
                headingConstraints +
                subHeadingConstraints +
                termsConditionDescriptionConstraints +
                termsConditionButtonConstraints +
                permissionButtonConstraints +
            thanksButtonContraints
        )
        
    }
    
}

extension SystemPermissionViewController {
    
    fileprivate func bind(viewModel: SystemPermissionViewModelType?) {
        guard let `viewModel` = viewModel else { return }
        bindDisplayableText(viewModel: viewModel)
        bindLoader(viewModel: viewModel)
        bindPermissionType(viewModel: viewModel)
        bindActions(viewModel: viewModel)
        bindError(viewModel: viewModel)
        bindDeviceToken(viewModel: viewModel)
        bindNoThanks(viewModel: viewModel)
    }
    
    private func bindLoader(viewModel: SystemPermissionViewModelType) { }
    
    private func bindDisplayableText(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.subHeading.bind(to: subHeadingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.termsConditionDescription.bind(to: termsDescriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.iconBackground.filter{ $0 != .clear}.subscribe(onNext: { [weak self] in
            self?.icon.backgroundColor = $0
            self?.icon.height(constant: 64)
            self?.icon.width(constant: 64)
            self?.icon.layer.cornerRadius = 32
            self?.icon.contentMode = .center
            self?.icon.clipsToBounds = true
        }).disposed(by: disposeBag)
    }
    
    private func bindDeviceToken(viewModel: SystemPermissionViewModelType) {
        let deviceToken = appDelegate.deviceToken.share()
        deviceToken.unwrap().map { _ in () }.bind(to: viewModel.inputs.successObserver).disposed(by: disposeBag)
        deviceToken.filter { $0 == nil }.map { _ in () }.bind(to: viewModel.inputs.onNoThanksObserver).disposed(by: disposeBag)
    }
    
    private func bindNoThanks(viewModel: SystemPermissionViewModelType) {
        thanksButton.rx.tap
            .map { _ in () }
            .bind(to: viewModel.inputs.onNoThanksObserver).disposed(by: disposeBag)
    }
    
    private func bindActions(viewModel: SystemPermissionViewModelType) {
        permissionButton.rx.tap.bind(to: viewModel.inputs.onPermissionObserver).disposed(by: disposeBag)
        
        viewModel.outputs.buttonTitle.subscribe(onNext: {[unowned self] title in
            self.permissionButton.setTitle(title, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.permissionType.map { $0 == .notification ? true : false }.bind(to: termsDescriptionLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.permissionType.map { $0 == .notification ? true : false }.bind(to: termsConditionButton.rx.isHidden).disposed(by: disposeBag)
        
    }
    
    private func bindPermissionType(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.permissionType.subscribe(onNext: {[unowned self] type in
            switch type {
            case .notification:
                self.widthConstraint = self.permissionButton.widthAnchor.constraint(equalToConstant: 280)
            default:
                self.widthConstraint = self.permissionButton.widthAnchor.constraint(equalToConstant: 192)
            }
            self.permissionType = type
        }).disposed(by: disposeBag)
    }
    
    private func bindError(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.error
            .subscribe(onNext: { _ in
            }).disposed(by: disposeBag)
    }
}

