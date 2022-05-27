//
//  SendMoneyFundsTransferViewController.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//



import UIKit
import YAPComponents
import RxTheme
import RxSwift

class SendMoneyFundsTransferViewController: KeyboardAvoidingViewController {
    
    // MARK: Views
    
    private lazy var formTableViewController: SendMoneyFundsTransferFormViewController = {
        let form = SendMoneyFundsTransferFormViewController(viewModel, themeService: self.themeService)
        form.view.translatesAutoresizingMaskIntoConstraints = false
        return form
    }()
    
    private lazy var amountAlert: YAPAlert = {
        let alert = YAPAlert()
        alert.translatesAutoresizingMaskIntoConstraints = false
        return alert
    }()
    
    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_next".localized, font: .large)
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    var viewModel: SendMoneyFundsTransferViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    init(_ viewModel: SendMoneyFundsTransferViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "common_button_cancel".localized, style: .plain, target: self, action: #selector(backAction))
        
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews()
    }
    
    func showAlert(msg message: String) {
        
        let attributedString = NSMutableAttributedString(string: "Psst…\n\n" + message)
        
        
        let paragraphStyle0 = NSMutableParagraphStyle()
        paragraphStyle0.alignment = .center
        
        let attributes0: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.title3,
            .paragraphStyle: paragraphStyle0
        ]
        attributedString.addAttributes(attributes0, range: NSRange(location: 0, length: 4))
        
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.alignment = .center
        
        let attributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.small,
            .paragraphStyle: paragraphStyle2
        ]
        attributedString.addAttributes(attributes2, range: NSRange(location: 5, length: message.count))
        
//        let alertView = YAPAlertView(icon: UIImage.init(named: "icon_card_expired_purple", in: .yapPakistan, compatibleWith: nil), text: attributedString, primaryButtonTitle: "OK, got it!".localized, cancelButtonTitle:nil)
//
//        alertView.rx.cancelTap.subscribe(onNext: {_ in
//        }).disposed(by: disposeBag)
//
//        alertView.rx.primaryTap.subscribe(onNext: {_ in
//
//        }).disposed(by: disposeBag)
        
        
        //alertView.show()
    }
    
    // MARK: Actions
    
    @objc
    private func backAction() {
        self.showAddBeneficiaryCancelAlert()
    }
    
    func showAddBeneficiaryCancelAlert() {
        
        showAddBeneficiaryCancelAlert(title:"screen_add_beneficiary_detail_display_text_cancel_popup_title".localized, message: "screen_add_beneficiary_detail_display_text_cancel_popup_message".localized, cancelButtonTitle: "common_button_cancel".localized, confirmButtonTitle: "common_button_confirm".localized, cancelButtonHandler: nil, confirmButtonHandler: { [weak self] _ in
        self?.viewModel.inputs.backObserver.onNext(())
              }, completion: nil)
    }
}

// MARK: View setup

private extension SendMoneyFundsTransferViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        addChild(formTableViewController)
        view.addSubview(formTableViewController.view)
        formTableViewController.didMove(toParent: self)
        
        view.addSubview(doneButton)
    }
    
    func setupConstraints() {
        formTableViewController.view
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right])
        
        doneButton
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 15)
            .toBottomOf(formTableViewController.view)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary)}, to: [navigationItem.rightBarButtonItem!.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [doneButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [doneButton.rx.disabledBackgroundColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension SendMoneyFundsTransferViewController {
    func bindViews() {
        viewModel.outputs.doneEnabled.bind(to: doneButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel.outputs.showError.subscribe(onNext: { [weak self] in
            self?.showAlert(message: $0, defaultButtonHandler: { [weak self] _ in
                self?.backAction()
            })
        }).disposed(by: disposeBag)
        
        viewModel.outputs.amountError
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                $0 == nil ? self.amountAlert.hide() :
                self.amountAlert.show(inView: self.view, type: .error, text: $0!, autoHides: false) })
            .disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.outputs.showActivity.bind(to: navigationController!.view.rx.showActivity).disposed(by: disposeBag)
        
//        let done = doneButton.rx.tap
//            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
//            .withLatestFrom(SessionManager.current.currentAccount.map{ $0?.restrictions.contains(.otpBlocked) ?? false })
//
//        done.filter{ $0 }.subscribe(onNext: { [weak self] _ in
//            UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
//        }).disposed(by: disposeBag)

        doneButton.rx.tap
            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
            .bind(to: viewModel.inputs.doneObserver).disposed(by: disposeBag)
        
    }
}
