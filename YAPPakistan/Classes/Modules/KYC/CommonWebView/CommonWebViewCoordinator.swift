//
//  CommonWebViewCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 22/02/2022.
//

import Foundation
import RxSwift
import YAPCore

class CommonWebViewCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer
    private var paymentGatewayM: PaymentGatewayLocalModel?
    private var html: String!
    private var resultObserver: AnyObserver<Void>?

    init(root: UINavigationController,
         container: KYCFeatureContainer, paymentGatewayM: PaymentGatewayLocalModel? = nil, html: String, resultObserver: AnyObserver<Void>? = nil) {
        self.root = root
        self.container = container
        self.paymentGatewayM = paymentGatewayM
        self.html = html
        self.resultObserver = resultObserver
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        cardDetailWebView()
        return result
    }
    
    private func cardDetailWebView() {
        let viewModel = CommonWebViewModel(container: container, repository: container.parent.makeCardsRepository(), html: self.html)
        let viewController = container.makeCommonWebViewController(viewModel: viewModel)
        
        let navigationRoot = makeNavigationController()
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.confirm.subscribe(onNext: { [weak self] model in
            guard let paymentGatewayObject = self?.paymentGatewayM else { return }
            paymentGatewayObject.cardDetailObject = model
            viewController.dismiss(animated: true, completion: {
                self?.addressPending()
            })
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.complete.subscribe(onNext:{ [weak self] obj in
            guard let observer = self?.resultObserver else { return }
            observer.onNext(())
            navigationRoot.dismiss(animated: true)
        })
            .disposed(by: rx.disposeBag)
        
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        self.root.present(navigationRoot, animated: true, completion: nil)
    }
    
    private func addressPending() {
        guard let paymentGatewayObject = self.paymentGatewayM else { return }
        coordinate(to: container.makeAddressCoordinator(root: root, paymentGatewayM: paymentGatewayObject))
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

extension CommonWebViewCoordinator {
    
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
