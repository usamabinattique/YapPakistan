//
//  CardStatementCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 28/04/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

public class CardStatementCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private var localNavRoot: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private let card: StatementFetchable?
    private var container: UserSessionContainer!
    let repository: StatementsRepositoryType
    
    public init(root: UIViewController, container: UserSessionContainer, card: StatementFetchable?, repository: StatementsRepositoryType) {
        self.root = root
        self.card = card
        self.container = container
        self.repository = repository
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = CardStatementViewModel(statementFetchable: card, repository: repository)
        let viewController = CardStatementViewController(themeService: container.themeService, viewModel: viewModel)
        
        self.localNavRoot = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        
        root.present(self.localNavRoot, animated: true, completion: nil)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localNavRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.customDateView.subscribe(onNext: { [weak self] _ in
            self?.showCustomDateView()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.viewStatement.withUnretained(self).subscribe(onNext: { `self`, request in
            //show webView
            self.showStatementDetail(webModel: request)
        }).disposed(by: rx.disposeBag)
        
        return result
    }
    
    private func showCustomDateView() {
        let viewModel = CustomDateStatementViewModel()
        let viewController = CustomDateStatementViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.back
            .subscribe(onNext: { [weak self] _ in
                self?.localNavRoot.popViewController()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.next
            .subscribe(onNext:{ [weak self] startD, endD in
                self?.localNavRoot.popViewController()
                print(startD)
                print(endD)
            })
            .disposed(by: rx.disposeBag)
        
        self.localNavRoot.pushViewController(viewController, animated: true)
    }
    
    func showStatementDetail(webModel: WebContentType) {
        coordinate(to: CardStatementWebViewCoordinator(root: self.localNavRoot, container: self.container, repository: self.repository, url: webModel.url?.absoluteString ?? ""))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    break
                case .cancel:
                    print("go back from Statement")
                    break
                }
            }).disposed(by: rx.disposeBag)
    }
}
