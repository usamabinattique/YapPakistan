//
//  CardSchemeCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxSwift
import YAPCore

class CardSchemeCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer
    private let navigation: NavigationContainerViewController

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
        self.navigation = container.makeNavigationContainerViewController()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        self.cardScheme()
        self.root.pushViewController(navigation, animated: true)
        return result
    }

    func cardScheme() {
        let viewController = container.makeCardSchemeViewController()
        self.navigation.childNavigation.pushViewController(viewController, animated: false)

//        viewController.viewModel.outputs.back.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in self.goBack() })
//            .disposed(by: rx.disposeBag)
//
//        viewController.viewModel.outputs.next.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in self.moveNext() })
//            .disposed(by: rx.disposeBag)
//
//        viewController.viewModel.outputs.edit.withUnretained(self)
//            .flatMap({ `self`, _ in self.editName() })
//            .bind(to: viewController.viewModel.inputs.nameObserver)
//            .disposed(by: rx.disposeBag)
    }

    func editName() -> Observable<String> {
        let viewController = container.makeEditCardNameViewController()
        navigation.childNavigation.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigation.childNavigation.popViewController(animated: true) })
            .disposed(by: rx.disposeBag)

        let next = viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.navigation.childNavigation.popViewController(animated: true) })

        return next
    }
}

// Helpers
fileprivate extension CardSchemeCoordinator {
    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }

    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}
