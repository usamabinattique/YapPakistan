//
//  PINViewController.swift
//  YAP
//
//  Created by Zain on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

/**
 
 */
public class PINViewController: UIViewController {

    // MARK: - Init
    public init(themeService: ThemeService<AppTheme>, viewModel: PINViewModelType, isCreatePasscode: Bool? = false) {
        self.themeService = themeService
        self.viewModel = viewModel
        self.isCreatePasscode = isCreatePasscode ?? false
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Views
    private lazy var holdingView = UIFactory.makeView()
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    private lazy var codeLabel = UIFactory.makeLabel(font: .title2, alignment: .center, charSpace: 10)
    private lazy var errorLabel: UILabel = UIFactory.makeLabel(font:.regular, alignment: .center)
    private lazy var pinKeyboard = UIFactory.makePasscodeKeyboard(
        font: .title2,
        biomatryImage: UIImage(named:  (BiometryType.faceID == BiometricsManager().deviceBiometryType) ? "icon_face_id":"icon_touch_id", in: .yapPakistan),
        backImage: UIImage(named: "icon_delete_purple", in: .yapPakistan)
    )
    // with: .greyDark
    private lazy var termsAndCondtionsLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    private lazy var termsAndCondtionsButton = UIFactory.makeButton(with: .micro, title: "screen_create_passcode_display_button_terms_and_conditions".localized)

    private lazy var createPINButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(font: .large)

    // MARK: - Properties
    let themeService: ThemeService<AppTheme>
    let viewModel: PINViewModelType
    let disposeBag: DisposeBag
    var hideNavigationBar: Bool = false
    var isCreatePasscode: Bool

    // MARK: - View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        bindTranslations()
    }

    public override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
        viewModel.inputs.backObserver.onCompleted()
        // self.dismiss(animated: true, completion: nil)
    }

    @objc func termsAndCondtionsTapped() {
        viewModel.inputs.termsAndConditionsActionObserver.onNext(())
        UIApplication.shared.open(URL(string: "https://www.yap.com/terms")!)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: false)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(isCreatePasscode ? true : hideNavigationBar, animated: false)
    }

}

// MARK: - Setup
fileprivate extension PINViewController {
    func setup() {
        setupViews()
        setupTheme()
        setupConstraints()
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
            .bind({ UIColor($0.primaryDark    ) }, to: [codeLabel.rx.textColor])
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
            .alignEdgesWithSuperview([.left, .right], constants: [55, 55])

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
            .width(constant: 200)
            .alignEdgeWithSuperviewSafeArea(.bottom,
                                            constant: bottomSafeArea)

    }
}

// MARK: - Bind
fileprivate extension PINViewController {
    func bind() {
        // viewModel.outputs.pinText.map{ $0?.string.count ?? 0 }.bind(to: dottedView.rx.characters).disposed(by: disposeBag)

        viewModel.outputs.pinText.map({$0?.string}).bind(to: codeLabel.rx.text).disposed(by: disposeBag)

        viewModel.outputs.pinValid.bind(to: createPINButton.rx.isEnabled).disposed(by: disposeBag)
        createPINButton.rx.tap.bind(to: viewModel.inputs.actionObserver).disposed(by: disposeBag)

        pinKeyboard.rx.keyTapped.bind(to: viewModel.inputs.pinChangeObserver).disposed(by: disposeBag)

        viewModel.outputs.error.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.pinText.map { _ -> String? in nil }.bind(to: errorLabel.rx.text).disposed(by: disposeBag)

        viewModel.outputs.enableBack
            .subscribe(onNext: { [unowned self] in
                if $0.0 {
                    self.addBackButton($0.1, backgroundColor: UIColor(themeService.attrs.primary), tintColor: .white)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shake
            .subscribe(onNext: { [unowned self] in
                self.codeLabel.animate([Animation.shake(duration: 0.1)])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hideNavigationBar.subscribe(onNext: {[weak self] in
            self?.hideNavigationBar = $0
        }).disposed(by: disposeBag)

        termsAndCondtionsButton.rx.tap
            .subscribe(onNext: { UIApplication.shared.open(URL(string: "https://www.yap.com/terms")!) })
            .disposed(by: rx.disposeBag)
    }

    func bindTranslations() {
        viewModel.outputs.headingText.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.termsAndConditionsText.subscribe(onNext: {[weak self] in
            if $0 == nil { self?.termsAndCondtionsLabel.isHidden = true }
            self?.termsAndCondtionsLabel.text = $0?.string
        }).disposed(by: disposeBag)
        viewModel.outputs.actionTitle.bind(to: createPINButton.rx.title()).disposed(by: disposeBag)
    }
}
