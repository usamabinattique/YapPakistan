//
//  KYCQuestionsCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/11/2021.
//

import Foundation
import RxSwift
import YAPCore

class KYCQuestionsCoordinator: Coordinator<ResultType<Void>> {
    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let progressRoot = container.makeKYCProgressViewController()
        root.pushViewController(progressRoot)

        Observable<Void>.just(()).withUnretained(self)
            .flatMap{ `self`, _ in self.motherNameQuestion() }.withUnretained(self)
            .flatMap{ `self`, name in self.cityQuestion(name) }.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.moveNext() })
            .disposed(by: rx.disposeBag)

        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.popViewController(progress: 0.25) })
            .disposed(by: rx.disposeBag)

        return result
    }

    func motherNameQuestion() -> Observable<String> {
        let viewController = container.makeMotherQuestionViewController()
        push(viewController: viewController, progress: 0.25)

        return viewController.viewModel.outputs.next
    }

    func cityQuestion(_ name: String) -> Observable<String> {
        let viewController = self.container.makeCityQuestionViewController(motherName: name)
        push(viewController: viewController, progress: 0.5)

        return viewController.viewModel.outputs.next
    }
}

// MARK: Helpers
fileprivate extension KYCQuestionsCoordinator {
    var progressRoot: KYCProgressViewController! { root.topViewController as? KYCProgressViewController }

    func push(viewController: UIViewController, progress: Float ) {
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.pushViewController(viewController, animated: true)
    }

    func popViewController(progress: Float) {
        guard self.progressRoot.childNavigation.viewControllers.count > 1 else {
            return moveBack()
        }
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.popViewController(animated: true)
    }

    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    func moveBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }
}
