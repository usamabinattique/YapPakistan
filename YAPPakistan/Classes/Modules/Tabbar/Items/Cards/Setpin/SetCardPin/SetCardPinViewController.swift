//
//  SetCardPinViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class SetCardPinViewController: UIViewController {

    // MARK: - Views
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    private lazy var pincodeView = UIFactory.makePincodeView()
    private lazy var pinKeyboard = UIFactory.makePasscodeKeyboard(font: .title2)
    private lazy var termsAndCondtionsView = UIFactory.makeTermsAndCondtionsView()
    private lazy var createPINButton = UIFactory.makeAppRoundedButton(with: .regular)
    private lazy var spacers = [ UIFactory.makeView(),
                                 UIFactory.makeView(),
                                 UIFactory.makeView(),
                                 UIFactory.makeView(),
                                 UIFactory.makeView() ]
    private var backButton: UIButton?

    // MARK: - Properties
    var themeService: ThemeService<AppTheme>!
    var viewModel: SetCardPinViewModelType!

    // MARK: - Init
    convenience init(themeService: ThemeService<AppTheme>,
                     viewModel: SetCardPinViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }

    // MARK: - View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        bindTranslations()
        setupTheme()
        setupConstraints()
        setupBinding()
    }

}

// MARK: - Setup
fileprivate extension SetCardPinViewController {

    func setupResources() {
        let imagename = (BiometricsManager().deviceBiometryType == .faceID) ? "icon_face_id" : "icon_touch_id"
        let bioImage = UIImage(named: imagename, in: .yapPakistan)
        let backImage = UIImage(named: "icon_delete_purple", in: .yapPakistan)
        pinKeyboard.biomatryButton.setImage(bioImage, for: .normal)
        pinKeyboard.backButton.setImage(backImage, for: .normal)
    }

    func bindTranslations() {
        viewModel.outputs.localizedText.withUnretained(self).subscribe(onNext: { `self`, string in
            self.headingLabel.text = string.heading
            self.termsAndCondtionsView.label.text = string.agrement
            self.termsAndCondtionsView.button.setTitle(string.terms, for: .normal)
            self.createPINButton.setTitle(string.next, for: .normal)
        }).disposed(by: rx.disposeBag)
    }

    func setupViews() {
        view.addSub(views: spacers)
        view.addSub(view: headingLabel)
            .addSub(view: pincodeView)
            .addSub(view: pinKeyboard)
            .addSub(view: termsAndCondtionsView)
            .addSub(view: createPINButton)
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary        ) }, to: [createPINButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark       ) }, to: [createPINButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.error          ) }, to: [pincodeView.errorLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [pincodeView.codeLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [termsAndCondtionsView.label.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [termsAndCondtionsView.button.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary        ) }, to: [pinKeyboard.rx.themeColor])
            .disposed(by: rx.disposeBag)

        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [backButton!.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        spacers[0]
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])

        headingLabel
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constant: 20)

        spacers[1]
            .toBottomOf(headingLabel)
            .alignEdgesWithSuperview([.left, .right])

        pincodeView
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right])

        spacers[2]
            .toBottomOf(pincodeView)
            .alignEdgesWithSuperview([.left, .right])

        pinKeyboard
            .toBottomOf(spacers[2])
            .centerHorizontallyInSuperview()
            .widthEqualToSuperView(multiplier: 251 / 375)

        spacers[3]
            .toBottomOf(pinKeyboard)
            .alignEdgesWithSuperview([.left, .right])

        termsAndCondtionsView
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()

        spacers[4]
            .toBottomOf(termsAndCondtionsView)
            .alignEdgesWithSuperview([.left, .right])

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2])
            .heightEqualTo(view: spacers[3])
            .heightEqualTo(view: spacers[4])

        createPINButton
            .toBottomOf(spacers[4])
            .alignEdgeWithSuperviewSafeArea(.safeAreaBottom, constant: 15)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 240)
    }
}

// MARK: - Bind
fileprivate extension SetCardPinViewController {
    func setupBinding() {
        viewModel.outputs.pinCode.bind(to: pincodeView.codeLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.isPinValid.bind(to: createPINButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: pincodeView.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.hideTermsView.bind(to: termsAndCondtionsView.rx.isHidden).disposed(by: rx.disposeBag)
//        viewModel.outputs.shake
//            .subscribe(onNext: { [weak self] in
//                self?.pincodeView.codeLabel.animate([Animation.shake(duration: 0.5)])
//                UINotificationFeedbackGenerator().notificationOccurred(.error)
//            })
//            .disposed(by: rx.disposeBag)
        
        createPINButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        pinKeyboard.rx.keyTapped.bind(to: viewModel.inputs.keyPressObserver).disposed(by: rx.disposeBag)
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)

        termsAndCondtionsView.button.rx.tap
            .subscribe(onNext: {
                UIApplication.shared.open(URL(string: "https://www.yap.com/terms")!)
            })
            .disposed(by: rx.disposeBag)
    }
}
