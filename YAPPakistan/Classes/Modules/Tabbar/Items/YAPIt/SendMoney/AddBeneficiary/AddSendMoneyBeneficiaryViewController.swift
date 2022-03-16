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
    
//    private lazy var formTableViewController: AddSendMoneyBeneficiaryFormTableViewController = {
//        let form = AddSendMoneyBeneficiaryFormTableViewController(viewModel)
//        form.view.translatesAutoresizingMaskIntoConstraints = false
//        return form
//    }()
//
    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton()
    private let statusView = UIFactory.makeBeneficiaryStatusView()
    private lazy var childContainerView = UIFactory.makeView()
    
    
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
//        hideKeyboardWhenTappedAround()
    }
    
    // MARK: Actions
    
    @objc
    private func backAction() {
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
        
        
//        addChild(formTableViewController)
//        view.addSubview(formTableViewController.view)
//        formTableViewController.didMove(toParent: self)
        
        childView?.translatesAutoresizingMaskIntoConstraints = false
        if childView != nil, childNavigation != nil {
            addChild(childNavigation!)
            view.addSubview(childView!)
        }
        childNavigation?.didMove(toParent: self)
        
        
       // view.addSubview(doneButton)
    }
    
    func setupResources() {
        statusView.strings = ["1", "2", "3"]
    }
    
    func setupConstraints() {
       statusView
            .alignEdgeWithSuperview(.top,constant: 12)
            .centerHorizontallyInSuperview()
        
        childView?
            .toBottomOf(statusView,constant: 32)
            .alignEdgesWithSuperview([.left,.right,.bottom])
//        doneButton
//            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 15)
//            .toBottomOf(formTableViewController.view)
//            .centerHorizontallyInSuperview()
//            .height(constant: 52)
//            .width(constant: 190)
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
        
      //  viewModel.outputs.progress.map{ Int($0) }.bind(to: statusView.rx.progress).disposed(by: disposeBag)
        
        viewModel.outputs.progress.subscribe(onNext: { [weak self] progress in
            print("status progoress \(progress)")
            self?.statusView.updateProgress(for: progress)
        }).disposed(by: disposeBag)

        
//        let done = doneButton.rx.tap
//            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
//            .withLatestFrom(SessionManager.current.currentAccount.map{ $0?.restrictions.contains(.otpBlocked) ?? false })
//        
//        done.filter{ $0 }.subscribe(onNext: { _ in
//            UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
//        }).disposed(by: disposeBag)
        
//        done.filter{ !$0 }.map{ _ in }
//            .do(onNext: { [weak self] in self?.view.endEditing(true) })
//            .bind(to: viewModel.inputs.doneObserver).disposed(by: disposeBag)
    }
}

