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

    fileprivate lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit, rendringMode: .alwaysTemplate)
    fileprivate lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    fileprivate lazy var subHeadingLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    fileprivate lazy var termsLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 2)
    fileprivate lazy var termsButton = UIFactory.makeButton(with: .small)
    fileprivate lazy var permissionButton = UIFactory.makeAppRoundedButton(with: .regular)
    fileprivate lazy var thanksButton = UIFactory.makeButton(with: .regular)

    fileprivate var themeService: ThemeService<AppTheme>!
    fileprivate var widthConstraint: NSLayoutConstraint?
    let viewModel: SystemPermissionViewModelType

    init (
        themeService: ThemeService<AppTheme>,
        viewModel: SystemPermissionViewModelType
    ) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        setupTheme()
        setupTranslations()
        setupConstraints()
        setupBindings()
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

    func setupTranslations() {
        termsButton.setTitle("screen_system_permission_text_terms_and_conditions".localized, for: .normal)
        thanksButton.setTitle("screen_system_permission_text_denied".localized, for: .normal)
    }

    fileprivate func setupConstraints() {
        icon.alignEdgesWithSuperview([.safeAreaTop], constant: 75)
            .centerHorizontallyInSuperview()

        headingLabel.toBottomOf(icon, constant: 47)
            .alignEdgesWithSuperview([.left, .right], constant: 30)

        subHeadingLabel.toBottomOf(headingLabel, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constant: 30)

        thanksButton.alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [0, 0, 30])
            .height(constant: 24)

        permissionButton.toTopOf(thanksButton, constant: 23)
            .centerHorizontallyInSuperview()
            .height(constant: 52)

        termsButton.toTopOf(permissionButton, constant: 31)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        termsLabel.toTopOf(termsButton)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        widthConstraint = permissionButton.widthAnchor.constraint(equalToConstant: 280)
        widthConstraint?.isActive = true    // Permission button width
    }
}

extension SystemPermissionViewController {

    fileprivate func setupBindings() {
        permissionButton.rx.tap.bind(to: viewModel.inputs.permissionObserver).disposed(by: rx.disposeBag)
        thanksButton.rx.tap.bind(to: viewModel.inputs.noThanksObserver).disposed(by: rx.disposeBag)
        termsButton.rx.tap.subscribe{ [weak self] _ in self?.openTermsAndConditions() }.disposed(by: rx.disposeBag)

        viewModel.outputs.loading.bind(to: rx.loader).disposed(by: rx.disposeBag)

        let resources = viewModel.outputs.resources

        resources.map({ $0.strings }).withUnretained(self)
            .subscribe(onNext: {
                $0.0.headingLabel.text = $0.1.heading
                $0.0.subHeadingLabel.text = $0.1.subHeading
                $0.0.termsLabel.text = $0.1.termsConditionDescription
                $0.0.termsButton.setTitle($0.1.termsConditionButtonTitle, for: .normal)
                $0.0.permissionButton.setTitle($0.1.buttonTitle, for: .normal)
            }).disposed(by: rx.disposeBag)

        resources.map({ $0.strings.buttonTitle }).withUnretained(self)
            .subscribe(onNext: {
                let atribs = [NSAttributedString.Key.font: UIFont.regular]
                let size = ($0.1 as NSString).size(withAttributes: atribs)
                $0.0.widthConstraint?.constant = size.width + 70
            }).disposed(by: rx.disposeBag)

        resources.map({ UIImage(named: $0.icon.name, in: .yapPakistan) })
            .bind(to: self.icon.rx.image)
            .disposed(by: rx.disposeBag)

        resources.filter{ $0.icon.isBackground }.map{ _ in () }.withUnretained(self)
            .subscribe(onNext: {
                $0.0.icon.backgroundColor = UIColor($0.0.themeService.attrs.primary).withAlphaComponent(0.15)
                $0.0.icon.height(constant: 64)
                $0.0.icon.width(constant: 64)
                $0.0.icon.layer.cornerRadius = 32
                $0.0.icon.contentMode = .center
                $0.0.icon.clipsToBounds = true
            }).disposed(by: rx.disposeBag)
    }
}
