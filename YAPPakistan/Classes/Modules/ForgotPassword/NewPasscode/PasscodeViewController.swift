//
//  PasscodeViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/09/2021.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

/**

 */
class PasscodeViewController: UIViewController {

    // MARK: - Views
    private lazy var holdingView = UIFactory.makeView()
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    private lazy var codeLabel = UIFactory.makeLabel(font: .title2, alignment: .center, charSpace: 10)
    private lazy var errorLabel: UILabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var pinKeyboard = UIFactory.makePasscodeKeyboard(font: .title2)
    private lazy var termsAndCondtionsLabel = UIFactory.makeLabel(font: .micro,
                                                                  alignment: .center,
                                                                  numberOfLines: 0,
                                                                  lineBreakMode: .byWordWrapping)
    private lazy var termsAndCondtionsButton = UIFactory.makeButton(with: .micro)
    private lazy var createPINButton = AppRoundedButtonFactory.createAppRoundedButton(font: .large)
    private var backButton: UIButton?

    // MARK: - Properties
    let themeService: ThemeService<AppTheme>
    let viewModel: PasscodeViewModelType
    var hideNavigationBar: Bool = false

    // MARK: - Init
    init(themeService: ThemeService<AppTheme>,
         viewModel: PasscodeViewModelType,
         backType: BackButtonType? = .backEmpty) {
        self.themeService = themeService
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        if let backType = backType { self.backButton = addBackButton(of: backType) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    @objc func termsAndCondtionsTapped() {
        viewModel.inputs.termsAndConditionsActionObserver.onNext(())
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: false)
    }

}

// MARK: - Setup
fileprivate extension PasscodeViewController {

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
            self.termsAndCondtionsLabel.text = string.agrement
            self.termsAndCondtionsButton.setTitle(string.terms, for: .normal)
            self.createPINButton.setTitle(string.action, for: .normal)
        }).disposed(by: rx.disposeBag)
    }

    func setupViews() {

        holdingView.addSubview(codeLabel)
        holdingView.addSubview(errorLabel)
        view.addSubview(headingLabel)
        view.addSubview(holdingView)
        view.addSubview(pinKeyboard)
        view.addSubview(termsAndCondtionsLabel)
        view.addSubview(termsAndCondtionsButton)
        view.addSubview(createPINButton)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary        ) }, to: [createPINButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark       ) }, to: [createPINButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.error          ) }, to: [errorLabel.rx.textColor])
            .bind({ UIColor($0.greyDark       ) }, to: [termsAndCondtionsLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [termsAndCondtionsButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary        ) }, to: [pinKeyboard.rx.themeColor])
            .bind({ UIColor($0.primary    ) }, to: [codeLabel.rx.textColor])
            .disposed(by: rx.disposeBag)

        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [backButton!.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        let spacer1 = UIFactory.makeView()
        let spacer2 = UIFactory.makeView()
        let spacer3 = UIFactory.makeView()
        let spacer4 = UIFactory.makeView()
        let spacer5 = UIFactory.makeView()
        view.addSub(view: spacer1)
            .addSub(view: spacer2)
            .addSub(view: spacer3)
            .addSub(view: spacer4)
            .addSub(view: spacer5)

        spacer1
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])
            .heightEqualTo(view: spacer2)
            .heightEqualTo(view: spacer3)
            .heightEqualTo(view: spacer4)
            .heightEqualTo(view: spacer5)

        headingLabel
            .toBottomOf(spacer1)
            .alignEdgesWithSuperview([.left, .right], constant: 20)

        codeLabel
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.top])
            .height(constant: 20)

        errorLabel
            .toBottomOf(codeLabel, constant: 3)
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.bottom])
            .height(constant: 20)

        spacer2
            .toBottomOf(headingLabel)
            .alignEdgesWithSuperview([.left, .right])

        holdingView
            .toBottomOf(spacer2)
            .alignEdgesWithSuperview([.left, .right])

        spacer3
            .toBottomOf(holdingView)
            .alignEdgesWithSuperview([.left, .right])

        pinKeyboard
            .toBottomOf(spacer3)
            .alignEdgesWithSuperview([.left, .right], constants: [60, 60])

        spacer4
            .toBottomOf(pinKeyboard)
            .alignEdgesWithSuperview([.left, .right])

        termsAndCondtionsLabel
            .toBottomOf(spacer4)
            .centerHorizontallyInSuperview()

        termsAndCondtionsButton
            .toBottomOf(termsAndCondtionsLabel)
            .centerHorizontallyInSuperview()

        spacer5
            .toBottomOf(termsAndCondtionsButton)
            .alignEdgesWithSuperview([.left, .right])

        let bottomSafeArea: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) == 0 ? 18 : 12
        createPINButton
            .toBottomOf(spacer5)
            .centerHorizontallyInSuperview()
            .height(constant: UIScreen.screenType == .iPhone5 || UIScreen.screenType == .iPhone6 ? 50 : 52)
            .width(constant: 240)
            .alignEdgeWithSuperviewSafeArea(.bottom,
                                            constant: bottomSafeArea)
    }
}

// MARK: - Bind
fileprivate extension PasscodeViewController {
    func setupBinding() {

        viewModel.outputs.pinText.bind(to: codeLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.pinValid.bind(to: createPINButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.shake
            .subscribe(onNext: { [unowned self] in
                self.codeLabel.animate([Animation.shake(duration: 0.1)])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            })
            .disposed(by: rx.disposeBag)

        createPINButton.rx.tap.bind(to: viewModel.inputs.actionObserver).disposed(by: rx.disposeBag)
        pinKeyboard.rx.keyTapped.bind(to: viewModel.inputs.keyPressObserver).disposed(by: rx.disposeBag)
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        termsAndCondtionsButton.rx.tap
            .subscribe(onNext: { UIApplication.shared.open(URL(string: "https://www.yap.com/terms")!) })
            .disposed(by: rx.disposeBag)
    }
}
