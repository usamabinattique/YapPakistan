//
//  TopupCardSelectionCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 22/02/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

class TopupCardSelectionCoordinator: Coordinator<ResultType<Void>> {
    
//    override var feature: CoordinatorFeature { .topUp }
    
//    init(root: UIViewController, successButtonTitle: String? = nil) {
//        self.root = root
//        self.successButtonTitle = successButtonTitle
//    }
    
    private let root: UINavigationController
    private var localRoot: UINavigationController!
    private let successButtonTitle: String?
    private let result = PublishSubject<ResultType<Void>>()
    private var container: KYCFeatureContainer
    private let repository: Y2YRepositoryType
    private let cardsRepository: CardsRepositoryType
    private let paymentGatewayM: PaymentGatewayLocalModel
    
    init(root: UINavigationController, container: KYCFeatureContainer, successButtonTitle: String? = nil,  repository: Y2YRepositoryType, cardsRepository: CardsRepositoryType, paymentGatewayM: PaymentGatewayLocalModel) {
        self.root = root
        self.successButtonTitle = successButtonTitle
        self.container = container
        self.repository = repository
        self.cardsRepository = cardsRepository
        self.paymentGatewayM = paymentGatewayM
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = TopupCardSelectionViewModel(repository: self.repository)
        let viewControlelr = TopupCardSelectionViewController(themeService: container.themeService, viewModel: viewModel)
   
//        root.pushViewController(viewControlelr, completion: nil)
//        root.setNavigationBarHidden(false, animated: false)
        
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewControlelr,themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        localRoot.setNavigationBarHidden(false, animated: false)
        root.present(localRoot, animated: true, completion: nil)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
//            self?.root.setNavigationBarHidden(true, animated: false)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    
        viewModel.outputs.addNewCard.subscribe(onNext: { [weak self] in
            self?.cardDetailWebView()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.beneficiarySelected.withUnretained(self).subscribe(onNext: { `self` ,externalPaymentCard in
            print("in topupcard selectionCoordinator")
            self.paymentGatewayM.beneficiary = externalPaymentCard
            self.addressPending()
        }).disposed(by: rx.disposeBag)

        
        return result.asObservable()
    }
    
    private func cardDetailWebView() {
        
        let apiConfig = self.container.mainContainer.makeAPIConfiguration()
        
        let viewModel = CommonWebViewModel(commonWebType: .onBoardingAddCardWeb, repository: self.cardsRepository, html: apiConfig.onBoardingCardDetailWebURL)
        let viewController = self.container.parent.makeCommonWebViewController(viewModel: viewModel)
        
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
    //    self.root.present(navigationRoot, animated: true, completion: nil) 
        localRoot.present(navigationRoot, animated: true, completion: nil)
    }
    
    private func addressPending() {
//        root.setNavigationBarHidden(true, animated: false)
        coordinate(to: container.makeAddressCoordinator(root: localRoot, paymentGatewayM: self.paymentGatewayM,isPresented: true))
            .subscribe(onNext: { [weak self] result in
//                self?.root.setNavigationBarHidden(false, animated: false)
                //self?.localRoot.setNavigationBarHidden(false, animated: false)
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

extension TopupCardSelectionCoordinator {
    
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

