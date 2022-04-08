//
//  StoreCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public class StoreCoordinator: Coordinator<ResultType<Void>> {

    private let root: UITabBarController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private let container: UserSessionContainer

    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewController = StoreViewController(viewModel: StoreViewModel(accountProvider: container.accountProvider))
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = true
        navigationRoot.tabBarItem = UITabBarItem(title: "Store",
                                                 image: UIImage(named: "icon_tabbar_store", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }
        
        viewController.viewModel.outputs.completeVerification
            .subscribe(onNext: { [weak self] isTrue in
                self?.navigateToKYC(isTrue)
            })
            .disposed(by: rx.disposeBag)

        return result
    }
    
    private func navigateToKYC( _ isTrue: Bool) {
        let kycContainer = KYCFeatureContainer(parent: container)
        
        if isTrue {
            coordinate(to: KYCCoordinator(container: kycContainer, root: self.navigationRoot))
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        self.navigationRoot.popToRootViewController(animated: true)
                    case .cancel:
                        break
                    }
                }).disposed(by: rx.disposeBag)
        } else {
            let viewController = kycContainer.makeManualVerificationViewController()
            
            viewController.viewModel.outputs.back.withUnretained(self)
                .subscribe(onNext: { `self`, _ in
                    self.root.setViewControllers([self.navigationRoot.viewControllers[0]], animated: true)
                })
                .disposed(by: rx.disposeBag)
            
            self.navigationRoot.pushViewController(viewController, animated: true)
            self.navigationRoot.setNavigationBarHidden(true, animated: true)
        }
    }
}

