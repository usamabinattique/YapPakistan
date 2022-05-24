//
//  TransactionDetailsCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

public class TransactionDetailsCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private var localNavRoot: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    let repository: TransactionsRepositoryType
    
    init(root: UIViewController, container: UserSessionContainer, repository: TransactionsRepositoryType) {
        self.root = root
        self.container = container
        self.repository = repository
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = TransactionDetailsViewModel(repository: self.repository)
        let viewController = TransactionDetailsViewController(themeService: container.themeService, viewModel: viewModel)
        
        self.localNavRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localNavRoot.setNavigationBarHidden(true, animated: false)
        localNavRoot.modalPresentationStyle = .fullScreen
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            self?.localNavRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        root.present(self.localNavRoot, animated: true, completion: nil)
        
        return result
    }
}
