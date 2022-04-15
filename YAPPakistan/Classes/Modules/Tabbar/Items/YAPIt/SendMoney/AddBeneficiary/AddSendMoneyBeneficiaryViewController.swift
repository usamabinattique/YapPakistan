//
//  AddSendMoneyBeneficiaryViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import UIKit
import RxCocoa
import RxSwift
import YAPCore
import YAPComponents
import RxTheme

class AddSendMoneyBeneficiaryViewController: UIViewController {
    
    // MARK: Views

    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton()
    private let statusView = UIFactory.makeBeneficiaryStatusView()
    private lazy var childContainerView = UIFactory.makeView()
    private lazy var accountAlert: YAPAlert = {
        return YAPAlert()
    }()
    
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private var viewModel: AddSendMoneyBeneficiaryViewModelType!
    private var themeService: ThemeService<AppTheme>
    private var childNavigation: UINavigationController?
    private var childView: UIView?
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme> ,_ viewModel: AddSendMoneyBeneficiaryViewModelType, childNavigation: UINavigationController?) {
        self.viewModel = viewModel
        self.themeService = themeService
        self.childNavigation = childNavigation
       
        self.childView = childNavigation?.view
        super.init(nibName: nil, bundle: nil)
        childNavigation?.view.frame = childContainerView.frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "common_button_cancel".localized, style: .plain, target: self, action: #selector(cancelAction))
        
        setupViews()
        setupConstraints()
        setupResources()
        setupTheme()
        bindViews()
        viewModel.inputs.progressObserver.onNext(.bankName)
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        accountAlert.hide()
        viewModel.inputs.backObserver.onNext(())
    }
    
    @objc
    private func cancelAction() {
        showAddBeneficiaryCancelAlert()
    }
}

// MARK: View setup

private extension AddSendMoneyBeneficiaryViewController {
    func setupViews() {
        view.addSubview(statusView)
        childView?.translatesAutoresizingMaskIntoConstraints = false
        if childView != nil, childNavigation != nil {
            addChild(childNavigation!)
            view.addSubview(childView!)
        }
        childNavigation?.didMove(toParent: self)
        
    }
    
    func setupResources() {
        statusView.strings = ["1", "2", "3"]
    }
    
    func setupConstraints() {
       statusView
            .alignEdgeWithSuperview(.top,constant: 12)
            .centerHorizontallyInSuperview()
            .height(constant: 32)
        
        childView?
            .toBottomOf(statusView,constant: 32)
            .alignEdgesWithSuperview([.left,.right,.bottom])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)}, to: [navigationItem.leftBarButtonItem!.rx.tintColor, navigationController!.navigationBar.rx.tintColor])
            .bind({ UIColor($0.primary)}, to: [navigationItem.rightBarButtonItem!.rx.tintColor])
            .bind({ (UIColor($0.primaryExtraLight), UIColor($0.primary)) }, to: [ statusView.rx.theme ])
            .disposed(by: rx.disposeBag)
    }
    
    func showAddBeneficiaryCancelAlert() {
        
        showAddBeneficiaryCancelAlert(title:"screen_add_beneficiary_detail_display_text_cancel_popup_title".localized, message: "screen_add_beneficiary_detail_display_text_cancel_popup_message".localized, cancelButtonTitle: "common_button_cancel".localized, confirmButtonTitle: "common_button_confirm".localized, cancelButtonHandler: nil, confirmButtonHandler: { [weak self] _ in
        self?.viewModel.inputs.cancelObserver.onNext(())
              }, completion: nil)
    }
}

// MARK: Binding

private extension AddSendMoneyBeneficiaryViewController {
    func bindViews() {
        viewModel.outputs.showsDone.map { !$0 }.bind(to: doneButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.doneText.bind(to: doneButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.doneEnabled.bind(to: doneButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.showActivity.bind(to: view.rx.showActivity).disposed(by: disposeBag)
        viewModel.outputs.endEditing.bind(to: view.rx.endEditting).disposed(by: disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        
        viewModel.outputs.progress.subscribe(onNext: { [weak self] progress in
            print("status progoress \(progress)")
            self?.statusView.updateProgress(for: progress)
        }).disposed(by: disposeBag)

        viewModel
            .outputs.bankDetailError.debug("Account Error")
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                        $0 == nil ? self.accountAlert.hide() : $0 != "" ? self.accountAlert.show(inView: self.view, type: .error, text: $0!, autoHides: true) : self.accountAlert.hide() })
            .disposed(by: disposeBag)
    }
}
