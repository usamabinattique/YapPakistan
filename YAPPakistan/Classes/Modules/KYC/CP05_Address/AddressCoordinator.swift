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
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
//        let progressView = container.makeKYCProgressViewController()
//
//        addAddressWith(progressView)
//
//        progressView.viewModel.inputs.progressObserver.onNext(0.75)
//        progressView.viewModel.outputs.backTap.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in self.goBack() })
//            .disposed(by: rx.disposeBag)
//        progressView.hidesBottomBarWhenPushed = true

        let navigationContainer = container.makeNavigationContainerViewController()
        root.pushViewController(navigationContainer, animated: true)

        let viewController = container.makeAddressViewController()
        navigationContainer.childNavigation.pushViewController(viewController, animated: false)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.goBack() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { [unowned self] _ in self.moveNext() })
            .disposed(by: rx.disposeBag)

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
}

// MARK: Helpers
fileprivate extension AddressCoordinator {
    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }
}
