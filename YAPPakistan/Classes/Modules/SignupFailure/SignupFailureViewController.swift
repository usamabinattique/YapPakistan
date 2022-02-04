//
//  SignupFailureViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 03/02/2022.
//

import UIKit
import YAPCore
import YAPComponents
import MessageUI
import RxSwift
import RxTheme

class SignupFailureViewController: UIViewController {

    // MARK: Views
    
    private lazy var labelTitle =  UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private lazy var image = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var labelDescription = UIFactory.makeLabel(font: .micro,alignment: .center, numberOfLines: 5)
    private lazy var flagImage = UIFactory.makeImageView()
    private lazy var logoutButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_light_dashboard_button_logout".localized)
    private lazy var reScanCNICButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_kyc_initial_review_rescan".localized)
    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_kyc_home_button_skip_no_dashboard".localized, for: .normal)
        button.titleLabel?.font = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var cnicAndSkipStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fillEqually, spacing: 24, arrangedSubviews: [reScanCNICButton,skipButton])
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: SignupFailureViewModelType!
    private let disposeBag = DisposeBag()
    private var confirmBottom: NSLayoutConstraint!
    private var backButton: UIButton!
    
    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: SignupFailureViewModelType) {

        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
        self.themeService = themeService
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        render()
        bindViews()
        setupTheme()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [labelDescription.rx.textColor])
            .bind({ UIColor($0.primaryDark)}, to: [labelTitle.rx.tintColor])
            .bind({ UIColor($0.primary)}, to: [logoutButton.rx.backgroundColor, reScanCNICButton.rx.backgroundColor, skipButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }

}

// MARK: View setup

private extension SignupFailureViewController {
    func setupViews() {
        view.backgroundColor = .white
         view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(labelTitle)
        scrollView.addSubview(image)
        scrollView.addSubview(labelDescription)
        scrollView.addSubview(cnicAndSkipStack)
        scrollView.addSubview(logoutButton)
        
//        reScanCNICButton.width = 230
//        reScanCNICButton.height = 52
        //skipButton.width = reScanCNICButton.width
        
    }

    func setupConstraints() {
        
        scrollView
            .alignEdgesWithSuperview([.left,.safeAreaTop,.safeAreaBottom,.right])
        contentView
            .alignEdgesWithSuperview([.left,.safeAreaTop,.safeAreaBottom,.right])
        contentView
            .widthEqualTo(view: scrollView)
            .heightEqualTo(view: scrollView,   priority: UILayoutPriority(250))
        
        
        labelTitle
            .alignEdgeWithSuperview(.top,constant: 94)
            .alignEdgeWithSuperview(.left,constant: 32)
            .alignEdgeWithSuperview(.right,constant: 32)

        image
            .alignEdgesWithSuperview([.left, .right], constant: 0)
            .toBottomOf(labelTitle,  constant: 0)
        
        labelDescription
            .alignEdgeWithSuperview(.left,constant: 32)
            .alignEdgeWithSuperview(.right,constant: 32)
            .toBottomOf(image, constant: 0)
            .toTopOf(logoutButton, .lessThanOrEqualTo  ,constant: 150)
        
        reScanCNICButton
            .centerHorizontallyInSuperview()
            .width(constant: 230)
            .height(constant: 52)
        
        skipButton
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .right], constant: 24)
        
        cnicAndSkipStack
            .centerHorizontallyInSuperview()
            .toBottomOf(labelDescription, .lessThanOrEqualTo ,constant: 140)
            .alignEdgeWithSuperview(.bottom,constant: 32)
            
            
        
        logoutButton
            .centerHorizontallyInSuperview()
            .width(constant: 230)
            .height(constant: 52)
            .toBottomOf(labelDescription, .lessThanOrEqualTo ,constant: 140)
            .alignEdgeWithSuperview(.bottom,constant: 32)
        
     
    }

    func render() {
        image.image = UIImage(named: "signup_failure", in: .yapPakistan)
        labelTitle.text = "screen_signup_failure_display_text_screen_title_cnic_linked_to_another_account".localized
        labelDescription.text =  "screen_signup_failure_display_text_screen_description_cnic_linked_to_another_account".localized
    }
}

// MARK: Binding

private extension SignupFailureViewController {
    func bindViews() {
        let shareHidden =  viewModel.outputs.isLogoutHidden.share()
//        shareHidden.bind(to: logoutButton.rx.isHidden).disposed(by: disposeBag)
//        shareHidden.map{ !$0 }.bind(to: cnicAndSkipStack.rx.isHidden,reScanCNICButton.rx.isHidden).disposed(by: disposeBag)
        shareHidden.subscribe(onNext: { [unowned self] isHidden in
            self.logoutButton.isHidden = isHidden
            self.cnicAndSkipStack.isHidden = !isHidden
            self.reScanCNICButton.isHidden = !isHidden
        }).disposed(by: disposeBag)

        
     /*   viewModel.outputs.userName.bind(to: userName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.balance.bind(to: balance.rx.attributedText).disposed(by: disposeBag)
       // viewModel.outputs.confirmEnabled.bind(to: confirmButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel.outputs.confirmEnabled.subscribe(onNext: { [weak self] isEnabled in
            print("isConfirmEnabled \(isEnabled)")
            self?.confirmButton.isEnabled = isEnabled
            self?.confirmButton.backgroundColor = isEnabled ? UIColor(Color(hex: "#5E35B1")) : UIColor(Color(hex: "#5E35B1")).withAlphaComponent(0.50)
        }).disposed(by: disposeBag)

        
//        viewModel.outputs.showError.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
        viewModel.outputs.currency.bind(to: currency.rx.text).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flagImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.isInputValid.subscribe(onNext: { [weak self] in
            //self?.amountView.amountTextField.layer.borderColor = ($0 ? UIColor.clear : UIColor.error).cgColor
            self?.amountView.amountTextField.layer.borderColor = ($0 ? UIColor.clear : UIColor.red).cgColor
        }).disposed(by: disposeBag)
        viewModel.outputs.fee.bind(to: feeLabel.rx.attributedText).disposed(by: disposeBag)

        viewModel.outputs.amountError
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                $0 == nil ? self.amountAlert.hide() :
                    self.amountAlert.show(inView: self.view, type: .error, text: $0!, autoHides: false) })
            .disposed(by: disposeBag)
        
        amountView.amountTextField.rx.text.map{ $0?.removingGroupingSeparator() }.bind(to: viewModel.inputs.amountObserver).disposed(by: disposeBag)
        noteTextField.rx.text.bind(to: viewModel.inputs.noteObserver).disposed(by: disposeBag)


        let done = confirmButton.rx.tap
            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
                .withLatestFrom( Observable.just(false) /*SessionManager.current.currentAccount.map{ $0?.restrictions.contains(.otpBlocked) ?? false } */)
//
        done.filter{ $0 }.subscribe(onNext: { _ in
         //   UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
        }).disposed(by: disposeBag)

        done.filter{ !$0 }.map{ _ in }
            .do(onNext: { [weak self] in self?.view.endEditing(true) })
            .bind(to: viewModel.inputs.confirmObserver).disposed(by: disposeBag)
        
        viewModel.outputs.allowedDecimalPlaces.subscribe(onNext: { [weak self] in
            self?.decimalPlaces = $0
        }).disposed(by: disposeBag)

        viewModel.outputs.coolingTransactionReminderAlert.subscribe(onNext: {[weak self] message in
                 guard let `msg` = message else { return }
                 self?.showAlert(msg: msg)
             }).disposed(by: disposeBag)
        
        viewModel.outputs.noteError.bind(to: noteTextField.rx.errorText).disposed(by: disposeBag)
        viewModel.outputs.noteError.map{ $0 == nil ? .normal : .invalid }
            .bind(to: noteTextField.rx.validationState).disposed(by: disposeBag)
        
        viewModel.outputs.showsFlag.subscribe(onNext: { [weak self] in
            self?.currencyStack.isHidden = !$0
            self?.paddedView.isHidden = !$0
            self?.amountView.isCurrencyHidden = $0
            self?.phoneNumber.isHidden = false //$0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.phoneNumber.bind(to: phoneNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag) */
    }
}

