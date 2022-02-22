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
    
    init(root: UINavigationController, container: KYCFeatureContainer, successButtonTitle: String? = nil,  repository: Y2YRepositoryType, cardsRepository: CardsRepositoryType) {
        self.root = root
        self.successButtonTitle = successButtonTitle
        self.container = container
        self.repository = repository
        self.cardsRepository = cardsRepository
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = TopupCardSelectionViewModel(repository: self.repository)
        let viewControlelr = TopupCardSelectionViewController(themeService: container.themeService, viewModel: viewModel)
   
        root.pushViewController(viewControlelr, completion: nil)
        root.setNavigationBarHidden(false, animated: false)
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
          //  self?.localRoot.dismiss(animated: true, completion: nil)
            self?.root.setNavigationBarHidden(true, animated: false)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
    
        viewModel.outputs.addNewCard.subscribe(onNext: { [weak self] in
            self?.cardDetailWebView()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.beneficiarySelected.withUnretained(self).subscribe(onNext: { `self` ,externalPaymentCard in
            
        }).disposed(by: rx.disposeBag)

        
        return result.asObservable()
    }
    
    private func cardDetailWebView() {
        
        var html = ""
        let myURLString = "https://pk-qa-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            html = myHTMLString
        } catch let error {
            print("Error: \(error)")
        }
        
        let viewModel = CommonWebViewModel(container: container, repository: cardsRepository, html: html)
        let viewController = container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
//        viewModel.outputs.confirm.subscribe(onNext: { [weak self] model in
//            self?.paymentGatewayM.cardDetailObject = model
//            viewController.dismiss(animated: true, completion: {
//                self?.addressPending()
//            })
//        }).disposed(by: rx.disposeBag)
//
        let navigationRoot = makeNavigationController()
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.pushViewController(viewController, completion: nil)
        self.root.present(navigationRoot, animated: true, completion: nil)
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

