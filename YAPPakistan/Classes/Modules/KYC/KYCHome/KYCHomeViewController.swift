//
//  B2CKYCHomeViewController.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCHomeViewController: UIViewController {

    // MARK: - Views

    private lazy var titleLabel = UIFactory.makeLabel(
        font: .title2,
        alignment: .center,
        text: "screen_kyc_home_display_text_screen_title".localized)

    private lazy var subHeadingLabel = UIFactory.makeLabel(
        font: .regular,
        alignment: .center,
        numberOfLines: 0,
        lineBreakMode: .byWordWrapping)

    private lazy var cardView: KYCDocumentView = {
        let view = KYCDocumentView()
        view.viewType = .detailsOnly
        view.title = "common_display_text_cnic".localized
        view.subTitle = "screen_kyc_home_cnic_scan".localized
        view.icon = UIImage(named: "kyc-user", in: .yapPakistan)
        return view
    }()

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var nextButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title = "common_button_next".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let themeService: ThemeService<AppTheme>

    let viewModel: KYCHomeViewModelType

    // MARK: - Init

    init(themeService: ThemeService<AppTheme>, viewModel: KYCHomeViewModelType) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()

        viewModel.inputs.documentsUploadObserver.onNext(())
    }

    // MARK: View Setup

    func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(cardView)
        view.addSubview(bottomStack)

        bottomStack.addArrangedSubview(nextButton)
        bottomStack.addArrangedSubview(skipButton)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeadingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.iconTintColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.titleColor)
            .bind({ UIColor($0.greyDark) }, to: cardView.rx.detailsColor)
            .bind({ UIColor($0.greyDark) }, to: cardView.rx.subTitleColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.subDetailsColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: skipButton.rx.titleColorForNormal)
            .disposed(by: disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .alignEdgeWithSuperview(.top, .lessThanOrEqualTo, constant: 50)
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 25)

        subHeadingLabel
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(titleLabel, constant: 10)

        cardView
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .alignEdge(.top, withView: subHeadingLabel, .lessThanOrEqualTo, constant: 100)
            .alignEdge(.top, withView: subHeadingLabel, .greaterThanOrEqualTo, constant: 50)
            .height(constant: 116)

        bottomStack
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)

        nextButton
            .width(constant: 190)
            .height(constant: 52)

        skipButton
            .height(constant: 30)
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.subHeadingText
            .bind(to: subHeadingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.nextButtonEnabled
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.skipButtonText
            .bind(to: skipButton.rx.title())
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextObserver)
            .disposed(by: disposeBag)

        skipButton.rx.tap
            .bind(to: viewModel.inputs.skipObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.eidValidation
            .bind(to: cardView.rx.validation)
            .disposed(by: disposeBag)

        viewModel.outputs.eidValidation
            .map { $0 == .valid
                ? "common_display_text_cnic".localized
                : "common_button_completed".localized
            }
            .bind(to: cardView.rx.details)
            .disposed(by: disposeBag)

        viewModel.outputs.eidValidation
            .map { $0 != .valid }
            .bind(to: cardView.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.showPermissionAlert.subscribe(onNext: { [unowned self] in
            self.showAlert(title: "common_display_text_permission_denied".localized,
                           message: "common_display_text_permission_camera".localized,
                           defaultButtonTitle: "common_button_settings".localized,
                           secondayButtonTitle: "common_button_cancel".localized,
                           defaultButtonHandler: { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, secondaryButtonHandler: nil, completion: nil)
        }).disposed(by: disposeBag)

        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: disposeBag)

        cardView.rx.tap
            .bind(to: viewModel.inputs.cardObserver)
            .disposed(by: disposeBag)
    }
}
