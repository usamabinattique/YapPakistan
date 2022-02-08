//
//  CardNameCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/11/2021.
//

import Foundation
import RxSwift
import YAPCore

class CardNameCoordinator: Coordinator<ResultType<Void>> {

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
        self.cardName()
        self.root.pushViewController(navigation, animated: true)
        return result
    }

    func cardName() {
        let viewController = container.makeCardNameViewController()
        self.navigation.childNavigation.pushViewController(viewController, animated: false)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.popViewController()
                self.goBack()
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.moveNext() })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.edit.withLatestFrom(viewController.viewModel.outputs.name).withUnretained(self)
            .flatMap({ `self`, name in self.editName(name: name) })
            .bind(to: viewController.viewModel.inputs.nameObserver)
            .disposed(by: rx.disposeBag)
    }

    func editName(name: String) -> Observable<String> {
        let viewController = container.makeEditCardNameViewController(name: name)
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
fileprivate extension CardNameCoordinator {
    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }

    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}
