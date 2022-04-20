//
//  SearchTransactionsCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 19/04/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

public class SearchTransactionsCoordinator: Coordinator<ResultType<Void>> {
    
    
    // MARK: Properties
    
    private let card: PaymentCard?
    private let root: UIViewController!
    private var localRoot: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private var categoryChangedResult: Bool = false
    private let disposeBag = DisposeBag()
    private let container: UserSessionContainer
    weak var viewModel:TransactionsViewModel?
    
    public init(card: PaymentCard? = nil, root: UIViewController, container: UserSessionContainer) {
        self.card = card
        self.root = root
        self.container = container
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = SearchTransactionsViewModel(card: card)
//        guard let viewModel = viewModel else {
//            return result.do(onNext: { [weak self] _ in self?.localRoot.dismiss(animated: true, completion: nil) })
//        }

        let viewController = SearchTransactionsViewController(viewModel: viewModel, themeService: container.themeService)
        
        localRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localRoot.navigationBar.isHidden = true
        localRoot.modalPresentationStyle = .fullScreen
        
        root.present(localRoot, animated: true, completion: nil)
        
        viewModel.outputs.close.subscribe(onNext: { [unowned self] in
            self.result.onNext(categoryChangedResult ? .success(()) : .cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionDetails.subscribe(onNext: { [weak self] in
            self?.navigateToDetails($0)
        }).disposed(by: disposeBag)
        
        return result.do(onNext: { [weak self] _ in self?.localRoot.dismiss(animated: true, completion: nil) })
    }
}

// MARK: Navigation

private extension SearchTransactionsCoordinator {
    func navigateToDetails(_ transaction: CDTransaction) {
       /* coordinate(to: TransactionDetailsCoordinator(cdTransaction: transaction, root: localRoot)).subscribe(onNext: {[weak self] result in
            if !(result.isCancel) {
                self?.categoryChangedResult = true
            }
        }).disposed(by: disposeBag) */
    }
}
