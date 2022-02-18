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
    private let schemeObj: KYCCardsSchemeM

    init(root: UINavigationController,
         container: KYCFeatureContainer, schemeObj: KYCCardsSchemeM) {
        self.container = container
        self.root = root
        self.navigation = container.makeNavigationContainerViewController()
        self.schemeObj = schemeObj
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
            .subscribe(onNext: { `self`, _ in
                self.schemeObj.isPaidScheme ? self.cardDetailWebView() : self.addressPending()
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.edit.withLatestFrom(viewController.viewModel.outputs.editNameForEditNameScreen).withUnretained(self)
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
    
    private func cardDetailWebView() {
        let viewModel = CommonWebViewModel(container: container, repository: container.parent.makeCardsRepository())
        let viewController = container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.confirm.subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true, completion: {
                self?.addressPending()
            })
        }).disposed(by: rx.disposeBag)

        let navigationRoot = makeNavigationController()
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        self.root.present(navigationRoot, animated: true, completion: nil)
    }
    
    private func addressPending() {
        coordinate(to: container.makeAddressCoordinator(root: root))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    print("go next from address")
                case .cancel:
//                    self?.navigationRoot.popToRootViewController(animated: true)
                    print("go back from address")
                    break
                }
            }).disposed(by: rx.disposeBag)
        
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

extension CardNameCoordinator {
    
    func makeNavigationController(_ root: UIViewController? = nil) -> UINavigationController {

            var navigation: UINavigationController!
            if let root = root {
                navigation = UINavigationController(rootViewController: root)
            } else {
                navigation = UINavigationController()
            }
            navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.regular, NSAttributedString.Key.foregroundColor: UIColor(container.themeService.attrs.primary)]
            navigation.modalPresentationStyle = .fullScreen
            navigation.navigationBar.barTintColor = UIColor(container.themeService.attrs.primary)
            navigation.interactivePopGestureRecognizer?.isEnabled = false
            navigation.navigationBar.isTranslucent = false
            navigation.navigationBar.isOpaque = true
            navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigation.navigationBar.shadowImage = UIImage()
            navigation.setNavigationBarHidden(false, animated: true)
            
            if #available(iOS 15, *) {
                let textAttributes = [NSAttributedString.Key.font: UIFont.regular, NSAttributedString.Key.foregroundColor: UIColor(container.themeService.attrs.primary)]
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.titleTextAttributes = textAttributes
                appearance.backgroundColor = UIColor.white // UIColor(red: 0.0/255.0, green: 125/255.0, blue: 0.0/255.0, alpha: 1.0)
                appearance.shadowColor = .clear  //removing navigationbar 1 px bottom border.
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            } else {
                
            }
            

            return navigation
        }
}

