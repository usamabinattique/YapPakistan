//
//  CardStatementWebViewCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 07/05/2022.
//

import Foundation
import RxSwift
import YAPCore

class CardStatementWebViewCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: UserSessionContainer
    private var statementM: WebContentType!
    private var repository: StatementsRepositoryType
    private let disposeBag = DisposeBag()

    init(root: UINavigationController, container: UserSessionContainer, repository: StatementsRepositoryType, statementModel: WebContentType) {
        self.root = root
        self.container = container
        self.repository = repository
        self.statementM = statementModel
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = CardStatementWebViewModel(repository: repository, statementModel: statementM)
        let viewController = CardStatementWebViewController(themeService: container.themeService, viewModel: viewModel)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            self?.root.popViewController()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.emailButton
            .subscribe(onNext: { [weak self] _ in
                self?.showEmailPopup()
            })
            .disposed(by: disposeBag)
        
        self.root.navigationBar.isHidden = false
        self.root.pushViewController(viewController)
        
        return result
    }
    
    func showEmailPopup() {
        let viewModel = StatementConfirmEmailViewModel(accountProvider: container.accountProvider, repository: container.makeTransactionsRepository(), statementModel: statementM)
        let viewController = StatementConfirmEmailViewController(themeService: container.themeService, viewModel: viewModel)
        
        viewModel.outputs.send
            .subscribe(onNext: { [unowned self] _ in
                viewController.completeHide(0)
                self.root.popViewController()
            }).disposed(by: disposeBag)
        
        viewModel.outputs.editEmail.subscribe(onNext:{ [weak self] _ in
            viewController.completeHide(0)
            self?.navigateToEditEmail()
                .subscribe(onNext: { [weak self] result in
                    guard let _ = self else { return }
                    switch result {
                    case .success:
                        self?.container.accountProvider.refreshAccount()
                            .subscribe(onNext: { _ in
                                self?.showEmailPopup()
                            }).disposed(by: self!.disposeBag)
                    case .cancel:
                        //print("OTP not verified")
                        break
                    }
                }).disposed(by: self!.disposeBag)
        }).disposed(by: disposeBag)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = YAPActionSheetRootViewController(nibName: nil, bundle: nil)
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        let nav = UINavigationController(rootViewController: viewController)

        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)

        viewController.window = alertWindow
    }
    
    fileprivate func navigateToEditEmail() -> Observable<ResultType<Void>> {
        return coordinate(to: ChangeEmailAddressCoordinator(root: self.root, container: self.container))
    }
}
