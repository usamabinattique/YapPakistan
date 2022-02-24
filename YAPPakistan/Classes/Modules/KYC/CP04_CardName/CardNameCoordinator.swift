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
    private var paymentGatewayM: PaymentGatewayLocalModel!

    init(root: UINavigationController,
         container: KYCFeatureContainer, schemeObj: KYCCardsSchemeM, paymentGatewayM: PaymentGatewayLocalModel) {
        self.container = container
        self.root = root
        self.navigation = container.makeNavigationContainerViewController()
        self.paymentGatewayM = paymentGatewayM
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
                guard let cardScheme = self.paymentGatewayM.cardSchemeObject else { return }
                if cardScheme.isPaidScheme {
                    if self.container.parent.accountProvider.currentAccountValue.value?.accountStatus == .cardSchemeExternalCardPending {
                        self.topupCardSelection()
                    } else {
                        self.cardDetailWeb()
                    }
                    
                } else {
                    self.addressPending()
                }
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
    
    private func cardDetailWeb() {
        //self.webView.load(URLRequest(url: URL(string: "https://pk-qa-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html")!))
        _ = coordinate(to: CommonWebViewCoordinator(root: root, container: container, paymentGatewayM: self.paymentGatewayM, html: "https://pk-qa-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html"))
    }
    
    private func addressPending() {
        coordinate(to: container.makeAddressCoordinator(root: root, paymentGatewayM: self.paymentGatewayM, isPresented: true))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    print("go next from Name address")
                case .cancel:
//                    self?.navigationRoot.popToRootViewController(animated: true)
                    print("go back from Name address")
                    break
                }
            }).disposed(by: rx.disposeBag)
        
    }
    
    func topupCardSelection() -> Observable<ResultType<Void>>  {
        return coordinate(to: container.makeTopupCardSelectionCoordinator(root: root, paymentGatewayM: paymentGatewayM))
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

