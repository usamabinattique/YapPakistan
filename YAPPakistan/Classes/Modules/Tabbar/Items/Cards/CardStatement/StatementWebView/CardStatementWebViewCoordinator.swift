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
    private var html: String!
    private var repository: StatementsRepositoryType

    init(root: UINavigationController, container: UserSessionContainer, repository: StatementsRepositoryType, url: String) {
        self.root = root
        self.container = container
        self.repository = repository
        self.html = url
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = CardStatementWebViewModel(repository: repository, url: html)
        let viewController = CardStatementWebViewController(themeService: container.themeService, viewModel: viewModel)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            self?.root.popViewController()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.emailButton
            .subscribe(onNext: { [weak self] _ in
                //self?.showEmailPopup()
            })
            .disposed(by: rx.disposeBag)
        
        self.root.navigationBar.isHidden = false
        self.root.pushViewController(viewController)
        
        return result
    }
    
    func showEmailPopup() {
        let viewModel = StatementConfirmEmailViewModel()
        let viewController = StatementConfirmEmailViewController(themeService: container.themeService, viewModel: viewModel)
        
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
}
