//
//  LiteDashboardViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents

class LiteDashboardViewController: UIViewController {

    // MARK: Views

    private lazy var logo = UIFactory.makeImageView(image: UIImage(named: "icon_app_logo", in: .yapPakistan),
                                                    contentMode: .scaleAspectFit)
    private lazy var headingLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .center,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)

    private lazy var logoutButton = UIFactory.makeAppRoundedButton(with: .large)

    private lazy var biometryLabel = UIFactory.makeLabel(font: .regular)

    private lazy var biometrySwitch = UIFactory.makeAppSwitch()

    private lazy var biometryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [biometryLabel, biometrySwitch])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var completeVerificationButton = UIFactory.makeAppRoundedButton(with: .large, title: "Complete verification")

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    var viewModel: LiteDashboardViewModelType!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: LiteDashboardViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewModel.inputs.viewAppearObserver.onNext(())
    }

    // MARK: View Setup

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(logo)
        view.addSubview(headingLabel)
        view.addSubview(logoutButton)
        view.addSubview(biometryStackView)
        view.addSubview(completeVerificationButton)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: logoutButton.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: biometryLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: completeVerificationButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        logo
            .alignEdgeWithSuperviewSafeArea(.top, constant: 120)
            .centerHorizontallyInSuperview()

        headingLabel
            .toBottomOf(logo, constant: 40)
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .centerHorizontallyInSuperview()

        logoutButton
            .toBottomOf(headingLabel, constant: 70)
            .height(constant: 52)
            .width(constant: 250)
            .centerHorizontallyInSuperview()

        biometryStackView
            .toBottomOf(logoutButton, constant: 20)
            .width(with: .width, ofView: logoutButton)
            .centerHorizontallyInSuperview()

        completeVerificationButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 250)
    }

    // MARK: Binding

    private func bindViewModel() {
        viewModel.outputs.biometrySupported.map { $0 }.subscribe(onNext: {[unowned self] isHidden in
            self.biometryLabel.isHidden = !isHidden
            self.biometrySwitch.isHidden = !isHidden
        }).disposed(by: disposeBag)

        viewModel.outputs.biometryTitle
            .map { "Sign in with \($0 ?? "")" }
            .bind(to: biometryLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.biometry
            .bind(to: biometrySwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.headingText
            .bind(to: headingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.logOutButtonTitle
            .bind(to: logoutButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .bind(to: viewModel.inputs.logoutObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.completeVerificationHidden
            .bind(to: completeVerificationButton.rx.isHidden)
            .disposed(by: disposeBag)

        completeVerificationButton.rx.tap
            .bind(to: viewModel.inputs.completeVerificationObserver)
            .disposed(by: disposeBag)

        biometrySwitch.rx.value
            .bind(to: viewModel.inputs.biometryChangeObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.showActivity
            .bind(to: view.rx.showActivity)
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .bind(to: rx.showErrorMessage)
            .disposed(by: disposeBag)
    }
}
