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

        Observable.just(())
            // .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(container.accountProvider.currentAccount).unwrap()
            .map({ $0.isSecretQuestionVerified }).withUnretained(self)
            .subscribe(onNext: { `self`, isVerified in
                  if isVerified == true {
                    self.cardOnItsWay()
                } else {
                    self.manualVerification()
                } 
            })
            .disposed(by: rx.disposeBag)

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
        let viewController = container.makeCardOnItsWayViewController()
        self.root.pushViewController(viewController)

        viewController.viewModel.outputs.back.debug("back button from result").withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                print("back from card on its way")
                self.root.popViewController(animated: true) {
                    self.goToHome()
                }
            })
            .disposed(by: rx.disposeBag)
    }

    func manualVerification() {
        let viewController = container.makeManualVerificationViewController()
        root.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.moveNext() })
            .disposed(by: rx.disposeBag)
    }
 }
