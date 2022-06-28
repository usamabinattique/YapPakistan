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
    private let container: UserSessionContainer
    private var navigation: UINavigationController!
    private var paymentGatewayM: PaymentGatewayLocalModel!
    private var disposeBag = DisposeBag()

    init(root: UINavigationController,
         container: UserSessionContainer, schemeObj: KYCCardsSchemeM, paymentGatewayM: PaymentGatewayLocalModel) {
        self.container = container
        self.root = root
        self.paymentGatewayM = paymentGatewayM
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        self.navigation = self.makeNavigationController()
        self.cardName()
        self.root.pushViewController(navigation, animated: true)
        return result
    }

    func cardName() {
//        let viewController = container.makeCardNameViewController(paymentGatewayM: paymentGatewayM)
//        self.navigation.childNavigation.pushViewController(viewController, animated: false)
//
//        viewController.viewModel.outputs.back.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in
//                self.root.popViewController()
//                self.goBack()
//            })
//            .disposed(by: disposeBag)
//
//        viewController.viewModel.outputs.next.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in
//                guard let cardScheme = self.paymentGatewayM.cardSchemeObject else { return }
//                if cardScheme.isPaidScheme {
//                    if self.container.parent.accountProvider.currentAccountValue.value?.accountStatus == .cardSchemeExternalCardPending {
//                        self.topupCardSelection()
//                            .subscribe(onNext: { _ in
//                                print("In cardName -> TopupCardSelection is subscribed")
//                            }).disposed(by: self.disposeBag)
//                    } else {
//                        self.cardDetailWeb()
//                    }
//
//                } else {
//                    self.addressPending()
//                }
//            })
//            .disposed(by: disposeBag)
//
//        viewController.viewModel.outputs.edit.withLatestFrom(viewController.viewModel.outputs.editNameForEditNameScreen).withUnretained(self)
//            .flatMap({ `self`, name in self.editName(name: name) })
//            .bind(to: viewController.viewModel.inputs.nameObserver)
//            .disposed(by: disposeBag)
        
        
    }

    func editName(name: String) -> Observable<String> {
        let viewController = container.makeEditCardNameViewController(name: name)
        navigation.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.navigation.popViewController(animated: true) })
            .disposed(by: disposeBag)

        let next = viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.navigation.popViewController(animated: true) })
        return next
    }
    
    private func cardDetailWeb() {
        let apiConfig = self.container.parent.makeAPIConfiguration()
        coordinate(to: CommonWebViewCoordinator(root: root, container: container, commonWebType: .onBoardingAddCardWeb, paymentGatewayM: self.paymentGatewayM, html: apiConfig.onBoardingCardDetailWebURL))
            .subscribe()
            .disposed(by: disposeBag)
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
            }).disposed(by: disposeBag)
        
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

