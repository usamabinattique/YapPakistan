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
    private var paymentGatewayM: PaymentGatewayLocalModel!

    init(root: UINavigationController,
         container: KYCFeatureContainer, paymentGatewayM: PaymentGatewayLocalModel) {
        self.root = root
        self.container = container
        self.paymentGatewayM = paymentGatewayM
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        cardDetailWebView()
        return result
    }
    
    private func cardDetailWebView() {
        let viewModel = CommonWebViewModel(container: container, repository: container.parent.makeCardsRepository())
        let viewController = container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.confirm.subscribe(onNext: { [weak self] model in
            self?.paymentGatewayM.cardDetailObject = model
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
        coordinate(to: container.makeAddressCoordinator(root: root, paymentGatewayM: self.paymentGatewayM))
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
