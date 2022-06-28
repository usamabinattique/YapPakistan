//
//  DashboardMissingDocumentCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 08/06/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore
import YAPCardScanner

public class DashboardMissingDocumentCoordinator: Coordinator<ResultType<Void>> {
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
//    public override var feature: CoordinatorFeature { .analytics }
    private var localNavigationController: UINavigationController!
   
    private let container: UserSessionContainer
    private let disposeBag = DisposeBag()

    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }

    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewModel = DashboardMissingDocumentViewModel(accountProvider: container.accountProvider, transactionRepository: container.makeTransactionsRepository())
        let viewController = DashboardMissingDocumentViewController(viewModel: viewModel, themeService: container.themeService)
        localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        localNavigationController?.isNavigationBarHidden = true
        root.present(localNavigationController!, animated: true, completion: nil)
        
        viewModel.outputs.doItLater.subscribe(onNext: { [weak self] in
            self?.root.dismiss(animated: true, completion: nil)
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.getStarted.unwrap().withUnretained(self).subscribe(onNext: { `self`, type in
            switch type {
            case .selfie:
                self.navigateTOSelfie()
            case .cnicCopy:
                self.cnicScanOcrReview().elements().subscribe(onNext: { result in
                switch result {
                case .cancel:
                    print("cancel scan")
                case .success(let identityResult):
                    print("success scan")
                }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        return result
    }

    private func navigateTOSelfie() {
        let kfcContainer = KYCFeatureContainer(parent: container)
        coordinate(to: kfcContainer.makeSelfieCoordinator(root: localNavigationController))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .cancel:
                    self?.localNavigationController.popViewController(animated: true, nil)
                default:
                    print("default")
                    break
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func cnicScanOcrReview() -> Observable<Event<ResultType<IdentityScannerResult>>> {
       return coordinate(to: CNICReScanCoordinator(container: container, root: localNavigationController, scanType: .update)).materialize()
    }
}
