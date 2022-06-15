//
//  KYCResultCoordinator.swift
//  Adjust
//
//  Created by Sarmad on 11/01/2022.
//

import Foundation
import RxSwift
import YAPCore

class KYCResultCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let account = container.accountProvider.currentAccountValue.value
        if account?.isSecretQuestionVerified == true {
            self.cardOnItsWay()
        } else {
            self.manualVerification()
        }

        return result
    }

}

// MARK: Helpers
fileprivate extension KYCResultCoordinator {
    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
    
    func goToHome() {
     //   self.root.popToRootViewController(animated: true)
        self.root.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

extension KYCResultCoordinator {
    func cardOnItsWay() {
        let viewModel = AccountOpenSuccessViewModel()
        let viewController = AccountOpenSuccessViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.gotoDashboard.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            print("Goto Dashboard button pressed")
        }).disposed(by: rx.disposeBag)
        
        self.root.pushViewController(viewController, completion: nil)
    }

    func manualVerification() {
        let viewController = container.makeManualVerificationViewController()
        root.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.popViewController(animated: true) {
                    self.goToHome()
                }
            })
            .disposed(by: rx.disposeBag)
    }
 }
