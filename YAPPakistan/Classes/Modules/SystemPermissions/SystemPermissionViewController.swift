//
// SystemPermissionViewController.swift
// App
//
// Created by Uzair on 18/06/2021.
//

import RxCocoa
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class SystemPermissionViewController: UIViewController {

    // swiftlint: disable force_cast
    // let appDelegate = UIApplication.shared.delegate as! PublicAppDelegate
    // swiftlint: enable force_cast

    fileprivate lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit, rendringMode: .alwaysTemplate)
    fileprivate lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    fileprivate lazy var subHeadingLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    fileprivate lazy var termsLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 2)
    fileprivate lazy var termsButton = UIFactory
        .makeButton(with: .small, title: "screen_system_permission_text_terms_and_conditions".localized)
    fileprivate lazy var permissionButton = UIFactory.makeAppRoundedButton(with: .regular)
    fileprivate lazy var thanksButton = UIFactory
        .makeButton(with: .regular, title: "screen_system_permission_text_denied".localized)

    fileprivate var themeService: ThemeService<AppTheme>!
    fileprivate let viewModel: SystemPermissionViewModelType
    fileprivate var widthConstraint: NSLayoutConstraint?
    fileprivate var permissionType: SystemPermissionType?
    fileprivate var notificationManager: NotificationManager
    fileprivate var username: String = ""

    init (
        themeService: ThemeService<AppTheme>,
        viewModel: SystemPermissionViewModelType,
        notificationManager: NotificationManager,
        username: String = ""
    ) {
        self.viewModel = viewModel
        self.username = username
        self.themeService = themeService
        self.notificationManager = notificationManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind(viewModel: viewModel)
        setupSubViews()
        setupTheme()
        setupConstraints()
    }

    @objc private func openTermsAndConditions() {
        let url = URL(string: "https://www.yap.com/uploads/EDB-Business-Banking-General-Terms-and-Conditions-Final-22082021.pdf")!
        UIApplication.shared.open(url, options: [: ], completionHandler: nil)
    }
}

extension SystemPermissionViewController {
    fileprivate func setupSubViews() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        view.addSubview(icon)
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(termsLabel)
        view.addSubview(termsButton)
        view.addSubview(permissionButton)
        view.addSubview(thanksButton)
    }

    fileprivate func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeadingLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: termsLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: termsButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primary) }, to: icon.rx.tintColor)
            .bind({ UIColor($0.primary) }, to: thanksButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primary) }, to: permissionButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: permissionButton.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)
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
            termsButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 0),
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsLabel.trailingAnchor, constant: 25)
        ]

        let termsConditionButtonConstraints = [
            permissionButton.topAnchor.constraint(equalTo: termsButton.bottomAnchor, constant: 31),
            termsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsButton.trailingAnchor, constant: 25)
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
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeading.bind(to: subHeadingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: rx.disposeBag)
        viewModel.outputs.termsConditionDescription.bind(to: termsLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.iconBackground.filter{ $0 != .clear }.subscribe(onNext: { [weak self] in
            self?.icon.backgroundColor = $0
            self?.icon.height(constant: 64)
            self?.icon.width(constant: 64)
            self?.icon.layer.cornerRadius = 32
            self?.icon.contentMode = .center
            self?.icon.clipsToBounds = true
        }).disposed(by: rx.disposeBag)
    }

    private func bindDeviceToken(viewModel: SystemPermissionViewModelType) {
        let deviceToken = notificationManager.deviceToken.share()
        deviceToken.unwrap().map { _ in () }
            .bind(to: viewModel.inputs.successObserver)
            .disposed(by: rx.disposeBag)
        deviceToken.filter { $0 == nil }.map { _ in () }
            .bind(to: viewModel.inputs.onNoThanksObserver)
            .disposed(by: rx.disposeBag)
    }

    private func bindNoThanks(viewModel: SystemPermissionViewModelType) {
        thanksButton.rx.tap
            .map { _ in () }
            .bind(to: viewModel.inputs.onNoThanksObserver).disposed(by: rx.disposeBag)
    }

    private func bindActions(viewModel: SystemPermissionViewModelType) {

        termsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in self?.openTermsAndConditions() })
            .disposed(by: rx.disposeBag)

        permissionButton.rx.tap.bind(to: viewModel.inputs.onPermissionObserver).disposed(by: rx.disposeBag)

        viewModel.outputs.buttonTitle.subscribe(onNext: {[unowned self] title in
            self.permissionButton.setTitle(title, for: .normal)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs
            .permissionType.map { $0 == .notification ? true : false }
            .bind(to: termsLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        viewModel.outputs
            .permissionType.map { $0 == .notification ? true : false }
            .bind(to: termsButton.rx.isHidden)
            .disposed(by: rx.disposeBag)

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
        }).disposed(by: rx.disposeBag)
    }

    private func bindError(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.error
            .subscribe(onNext: { _ in
            }).disposed(by: rx.disposeBag)
    }
}

