//
//  SignInVerifyPasscodeViewController.swift
//  App
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

public class PasscodeViewController: UIViewController {

    // fileprivate var disposeBag = DisposeBag()
    // var passcodeDisposeBag = DisposeBag()
    // private let viewModel: PasscodeViewModelType

    fileprivate lazy var biometricsManager = BiometricsManager()

    fileprivate lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = .title3
        label.text = /* UIScreen.screenType == ScreenType.iPhone5 ? "" : */ "screen_verify_passcode_display_text_title".localized
        label.textColor = UIColor.blue // .appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var incorrectAttemptsLabel: UILabel = { let label = UIFactory.makeLabel(alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
        label.textColor = .red // with: .error, textStyle: .regular,
        return label
    }()

    lazy var inValidCredentialsMessageLabel: UILabel = {
        let label = UIFactory.makeLabel(alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, adjustFontSize: true)
        label.textColor = .red // with: .error, textStyle: .regular,
        return label
    }()

    lazy var appLogo: UIImageView = UIFactory.makeImageView(image: UIImage(named: "icon_app_logo", in: Bundle(for: Self.self), compatibleWith: nil), contentMode: .scaleAspectFit)

    lazy var passcodeDots: PasscodeDottedView = {
        let dots = PasscodeDottedView()
        dots.translatesAutoresizingMaskIntoConstraints = false
        return dots
    }()

    lazy var errorStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, arrangedSubviews: [incorrectAttemptsLabel, inValidCredentialsMessageLabel])

    private lazy var holdingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var passcodeKeys: RxPasscodeKeyboard = {
        var isEnabled = false
        // viewModel.outputs.biometricsEnabled.subscribe(onNext: { isEnabled = $0 }).dispose()
        let keyboard = RxPasscodeKeyboard(biometryEnabled: isEnabled)
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        return keyboard
    }()

    fileprivate lazy var nextButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.setTitle( "screen_verify_passcode_button_sign_in".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        return button
    }()

    fileprivate lazy var forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle( "screen_verify_passcode_text_forgot_password".localized, for: .normal)
        button.setTitleColor(UIColor.blue /*.appColor(ofType: .primary)*/, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var alert: YAPAlert = {
        let alert = YAPAlert()
        alert.translatesAutoresizingMaskIntoConstraints = false
        return alert
    }()

    private lazy var buttonStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [nextButton, forgotPasswordButton])

    public init(/*viewModel: PasscodeViewModelType*/) {
        // self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        lowEndPhoneChecks()
        setupSubViews()
        setupConstraints()
        bind()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewModel.inputs.biometricsAuthenticateObserver.onNext(())
        // viewModel.inputs.viewWillAppearObserver.onNext(())
        passcodeBinding()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // viewModel.inputs.passcodeObserver.onNext("")
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        YAPProgressHud.hideProgressHud()
    }

    /// override public func onTapBackButton() {
    ///    viewModel.inputs.backObserver.onNext(())
    /// }

}

extension PasscodeViewController {
    fileprivate func setupSubViews() {
        // addBackButton(navigationController?.viewControllers.count ?? 0 > 1 ? .backCircled : .closeCircled)
        view.backgroundColor = .white
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [UIRectEdge.top]
        self.navigationItem.titleView = appLogo
        view.addSubview(headingLabel)
        holdingView.addSubview(passcodeDots)
        holdingView.addSubview(errorStackView)
        view.addSubview(holdingView)
        view.addSubview(passcodeKeys)
        view.addSubview(buttonStack)

    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    fileprivate func setupConstraints() {

        appLogo
            .height(constant: 25)
            .width(with: .height, ofView: appLogo, multiplier: 3.0)

        headingLabel
            .alignEdge(.left, withView: view, constant: 20)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.top, constant: 10)
            .height(.greaterThanOrEqualTo, constant: 40)

        passcodeDots
            .centerInSuperView()
            .height(constant: 16)

        errorStackView
            .toBottomOf(passcodeDots, constant: 3)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        holdingView
            .toBottomOf(headingLabel, constant: 1)
            .toTopOf(passcodeKeys)
            .alignEdgesWithSuperview([.left, .right])
            .height(.lessThanOrEqualTo, constant: 140)
            .height(.greaterThanOrEqualTo, constant: 85)

        passcodeKeys
            .alignEdgesWithSuperview([.left, .right], constants: [55, 55])
            .toBottomOf(holdingView, .lessThanOrEqualTo, constant: 60)
            .toBottomOf(holdingView, .greaterThanOrEqualTo, constant: 0)

        buttonStack
            .toBottomOf(passcodeKeys, .lessThanOrEqualTo, constant: 25)
            .toBottomOf(passcodeKeys, .greaterThanOrEqualTo, constant: 10)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 12)

        nextButton
            .height(constant: 52)
            .width(constant: 200)

        forgotPasswordButton
            .height(constant: 30)
            .width(constant: 200)
    }

    fileprivate func lowEndPhoneChecks(){
        //// switch UIScreen.screenType {
        /// case .iPhone5, .iPhone6:
        ///    inValidCredentialsMessageLabel.font = UIFont.small
            incorrectAttemptsLabel.font = UIFont.small
            headingLabel.font = UIFont.large
        /// case .iPhone6Plus:
        ///    inValidCredentialsMessageLabel.font = UIFont.small
        ///    incorrectAttemptsLabel.font = UIFont.small
        /// default:
        ///    break
        /// }
    }
}

extension PasscodeViewController {

    private func bind() {
       /* viewModel.inputs.checkBiometricsEnabledObserver.onNext(())
        viewModel.outputs.biometricsEnabled.bind(to: passcodeKeys.rx.biometryEnable).disposed(by: rx.disposeBag)
        passcodeKeys.rx.biometricsButtonTap.bind(to: viewModel.inputs.biometricsAuthenticateObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.passcode.map { $0.count }.bind(to: passcodeDots.rx.characters).disposed(by: rx.disposeBag)
        viewModel.outputs.loginButtonTitle.bind(to: nextButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        nextButton.rx.tap.subscribe(onNext: {[unowned self] _ in
            if CheckInternetConnectivity.isConnectedToInternet {
                self.viewModel.inputs.nextObserver.onNext(()) }
            else{
                self.alert.show(inView: self.view, type: .error, text:  "common_display_text_error_no_internet".localized, autoHides: true)
            }
        }).disposed(by: rx.disposeBag)
        forgotPasswordButton.rx.tap.bind(to: viewModel.inputs.forgotPasswordObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.error.map { _ in () }.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.passcodeDots.animate([Animation.shake(duration: 0.1)])
            let hepticTouchFeedback = UINotificationFeedbackGenerator()
            hepticTouchFeedback.notificationOccurred(.error)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.allowPasscodeReset.not().bind(to: forgotPasswordButton.rx.isHidden).disposed(by: rx.disposeBag)
        
        let inValidCredentialsErrorMessage = viewModel.outputs.inValidCredentialsErrorMessage.share(replay: 1, scope: .whileConnected)
        
        inValidCredentialsErrorMessage.map { $0 == nil ? true : false }.bind(to: inValidCredentialsMessageLabel.rx.isHidden).disposed(by: rx.disposeBag)
        inValidCredentialsErrorMessage.unwrap().bind(to: inValidCredentialsMessageLabel.rx.text).disposed(by: rx.disposeBag)
        
        let incorrectAttemptsReached = viewModel.outputs.incorrectAttemptsReached.share(replay: 1, scope: .whileConnected)
        incorrectAttemptsReached.map { $0 == nil ? true : false }.bind(to: incorrectAttemptsLabel.rx.isHidden).disposed(by: rx.disposeBag)
        incorrectAttemptsReached
            .unwrap()
            .do(onNext: {[unowned self] _ in self.inValidCredentialsMessageLabel.isHidden = true })
            .bind(to: incorrectAttemptsLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.isKeypadLocked.not().bind(to: passcodeKeys.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.isConfirmEnabled.bind(to: nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        let accountLocked = viewModel.outputs.accountLocked.share(replay: 1, scope: .whileConnected)
        accountLocked
            .do(onNext: {[unowned self] _ in self.inValidCredentialsMessageLabel.isHidden = true })
            .bind(to: incorrectAttemptsLabel.rx.text).disposed(by: rx.disposeBag)
        accountLocked.map { _ in false }.bind(to: incorrectAttemptsLabel.rx.isHidden).disposed(by: rx.disposeBag)
        accountLocked.map { _ in true }.bind(to: passcodeDots.rx.isHidden).disposed(by: rx.disposeBag)
        
        let accountFreezed = viewModel.outputs.accountFreezed.share(replay: 1, scope: .whileConnected)
        accountFreezed
            .do(onNext: {[unowned self] _ in self.inValidCredentialsMessageLabel.isHidden = true })
            .bind(to: incorrectAttemptsLabel.rx.text).disposed(by: rx.disposeBag)
        accountFreezed.map { _ in false }.bind(to: incorrectAttemptsLabel.rx.isHidden).disposed(by: rx.disposeBag)
        accountFreezed.map { _ in true }.bind(to: passcodeDots.rx.isHidden).disposed(by: rx.disposeBag)
        
        viewModel.outputs.errorAlert.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
        
        //        Observable.of("DDsdsdsdfsdff").bind(to: incorrectAttemptsLabel.rx.text).disposed(by: rx.disposeBag)
 */
    }

    private func passcodeBinding() {
   /*     passcodeKeys.rx.output.do(onNext: {[unowned self] _ in self.inValidCredentialsMessageLabel.isHidden = true })
            .scan("") { lastValue, newValue -> String in
                if newValue == String(UnicodeScalar(0)) { return "" } else if newValue == String(UnicodeScalar(8))
         { return String(lastValue.dropLast()) } else if lastValue.count >= 6 { return  lastValue } else { return lastValue + newValue }
                
        }.bind(to: viewModel.inputs.passcodeObserver).disposed(by: passcodeDisposeBag)
        
        viewModel.outputs.clearPasscode.bind(to: passcodeKeys.rx.clearTextObserver).disposed(by: rx.disposeBag) */
    }
}
