//
//  VerifyPasscodeViewController.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

public class VerifyPasscodeViewController: UIViewController {

    // MARK: - Views
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0)
    private lazy var holdingView = UIFactory.makeView()
    private lazy var codeLabel = UIFactory.makeLabel(font: .title2, alignment: .center, charSpace: 10)
    private lazy var errorLabel = UIFactory.makeLabel(font:.regular, alignment: .center, numberOfLines: 0)
    private lazy var pinKeyboard = UIFactory.makePasscodeKeyboard(font:.title2)
    private lazy var signinButton = UIFactory.makeAppRoundedButton(with: .regular)
    private lazy var forgotButton = UIFactory.makeButton(with: .regular)
    private var backButton:UIButton!
    
    // MARK: - Properties
    let themeService: ThemeService<AppTheme>
    let viewModel: VerifyPasscodeViewModelType
    let biometricsService: BiometricsManager
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>,
         viewModel: VerifyPasscodeViewModelType,
         biometricsService: BiometricsManager) {
        
        self.themeService = themeService
        self.viewModel = viewModel
        self.biometricsService = biometricsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
        setupBindings()
        setupConstraints()
    }

}

fileprivate extension VerifyPasscodeViewController {

    func setupSubViews() {
        holdingView.addSubview(codeLabel)
        holdingView.addSubview(errorLabel)
        view.addSubview(headingLabel)
        view.addSubview(holdingView)
        view.addSubview(pinKeyboard)
        view.addSubview(signinButton)
        view.addSubview(forgotButton)
        backButton = self.addBackButton(of: .closeCircled)
    }

    func setupResources() {
        let biomImgName: String = (BiometryType.faceID == BiometricsManager().deviceBiometryType) ?
                "icon_face_id":"icon_touch_id"
        let bioMImg = UIImage(named: biomImgName, in: .yapPakistan)
        let backImg = UIImage(named: "icon_delete_purple", in: .yapPakistan)
        
        pinKeyboard.biomatryButton.setImage(bioMImg, for: .normal)
        pinKeyboard.backButton.setImage(backImg?.asTemplate, for: .normal)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary        ) }, to: [signinButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark       ) }, to: [signinButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.error          ) }, to: [errorLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [pinKeyboard.rx.themeColor])
            .bind({ UIColor($0.primary        ) }, to: [codeLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [forgotButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
        
        guard let backButton = backButton else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    func setupLocalizedStrings() {
        viewModel.outputs.localizedText.withUnretained(self).subscribe { (self, string) in
            self.headingLabel.text = string.heading
            self.signinButton.setTitle(string.signIn, for: .normal)
            self.forgotButton.setTitle(string.forgot, for: .normal)
        }.disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        
        viewModel.outputs.pinText.bind(to: codeLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.pinValid.bind(to: signinButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.shake.subscribe(onNext: { [weak self] in self?.codeLabel.shake() }).disposed(by: rx.disposeBag)
        
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        pinKeyboard.rx.keyTapped.bind(to: viewModel.inputs.keyPressObserver).disposed(by: rx.disposeBag)
        signinButton.rx.tap.bind(to: viewModel.inputs.actionObserver).disposed(by: rx.disposeBag)

        //
        //
        //
        //viewModel.outputs.pinText.map { _ -> String? in nil }.bind(to: errorLabel.rx.text).disposed(by: rx.disposeBag)
        //viewModel.outputs.shake
        //    .subscribe(onNext: { [unowned self] in
        //        self.codeLabel.animate([Animation.shake(duration: 0.1)])
        //        UINotificationFeedbackGenerator().notificationOccurred(.error)
        //    })
        //    .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        let spacer1 = UIFactory.makeView()
        let spacer2 = UIFactory.makeView()
        let spacer3 = UIFactory.makeView()
        let spacer4 = UIFactory.makeView()
        view.addSub(view: spacer1)
            .addSub(view: spacer2)
            .addSub(view: spacer3)
            .addSub(view: spacer4)

        spacer1
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])
            .heightEqualTo(view: spacer2)
            .heightEqualTo(view: spacer3)
            .heightEqualTo(view: spacer4)

        headingLabel
            .toBottomOf(spacer1)
            .alignEdgesWithSuperview([.left, .right], constant: 20)
    
        codeLabel
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.top])
            .height(constant: 20)

        errorLabel
            .toBottomOf(codeLabel, constant: 3)
            .alignEdgesWithSuperview([.right, .left], constant: 19)
            .alignEdgesWithSuperview([.bottom])
            .heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true //.height(constant: 20)

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
        
        signinButton
            .toBottomOf(spacer4)
            .centerHorizontallyInSuperview()
            .height(constant: UIScreen.screenType == .iPhone5 || UIScreen.screenType == .iPhone6 ? 50 : 52)
            .width(constant: 200)
        
        forgotButton
            .toBottomOf(signinButton, constant: 20)
            .alignEdgesWithSuperview([.safeAreaBottom], constant: 30)
            .centerHorizontallyInSuperview()
    }

}
