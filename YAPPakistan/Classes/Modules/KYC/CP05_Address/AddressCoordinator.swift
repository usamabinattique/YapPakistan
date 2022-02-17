//
//  AddressCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/11/2021.
//

import Foundation
import RxSwift
import YAPCore

class AddressCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
        
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let progressRoot = container.makeKYCProgressViewController()
        root.pushViewController(progressRoot)
        
        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.goBack()
                self.root.popViewController()
            })
            .disposed(by: rx.disposeBag)
        progressRoot.hidesBottomBarWhenPushed = true

        let viewController = container.makeAddressViewController()
        push(viewController: viewController, progress: 0.90)

        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)

//        viewController.viewModel.outputs.next.withUnretained(self)
//            .subscribe(onNext: { [unowned self] _ in self.moveNext() })
//            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.withUnretained(self)
            .flatMap({ `self`, _ in self.kycResult().materialize() }).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.goToHome() })
            .disposed(by: rx.disposeBag)
//
//
//        viewController.viewModel.outputs.next.withUnretained(self)
//                .flatMap({ `self`, _ in self.kycResult().materialize() }).withUnretained(self)
//                .subscribe(onNext: { `self`, _ in self.goToHome() })
//                .disposed(by: rx.disposeBag)
//
//        Observable.combineLatest(viewController.viewModel.inputs.reloadAndNextObserver, viewController.viewModel.outputs.next)
//            .delay(.milliseconds(500), scheduler: MainScheduler.instance).withUnretained(self)
//            .subscribe(onNext: { _ in
//                let vcs = self.root.viewControllers
//                self.root.viewControllers.removeSubrange(2..<(vcs.count - 1))
//            })
//            .disposed(by: rx.disposeBag)
        
        return result
    }

    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()
        let navigation = container.makeNavigationController(root: viewController)
        root.present(navigation, animated: true)

        viewController.viewModel.outputs.back
            .subscribe(onNext: { [weak self] _ in self?.root.dismiss(animated: true) })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.root.dismiss(animated: true) })
    }
    
    func kycResult() -> Observable<ResultType<Void>> {
        return coordinate(to: KYCResultCoordinator(root: root, container: container))
    }
    
    func goToHome() {
        self.root.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

// MARK: Helpers
fileprivate extension AddressCoordinator {
    var progressRoot: KYCProgressViewController! { root.topViewController as? KYCProgressViewController }

    func push(viewController: UIViewController, progress: Float ) {
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.pushViewController(viewController, animated: true)
    }

    func popViewController(progress: Float) {
//        guard self.progressRoot.childNavigation.viewControllers.count > 1 else {
//            return goBack()
//        }
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.popViewController(animated: true)
    }
    
    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }
}
