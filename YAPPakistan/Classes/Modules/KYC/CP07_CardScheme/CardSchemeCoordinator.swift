//
//  CardSchemeCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxSwift
import YAPCore

class CardSchemeCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController
    private var navigationRoot: UINavigationController!
    private let container: KYCFeatureContainer
    private var paymentGateawayM: PaymentGateawayLocalModel!

    init(root: UINavigationController,
         container: KYCFeatureContainer, paymentGateawayM: PaymentGateawayLocalModel) {
        self.container = container
        self.root = root
        self.paymentGateawayM = paymentGateawayM
        
        super.init()
        
        self.navigationRoot = makeNavigationController()
        self.navigationRoot.modalPresentationStyle = .fullScreen
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let progressRoot = container.makeKYCProgressViewController()
        root.pushViewController(progressRoot)
        
        cardScheme()
            .subscribe(onNext:{ [weak self] cardSchemeObj in
                guard let `self` = self else { return }
                self.paymentGateawayM.cardSchemeObject = cardSchemeObj
                switch cardSchemeObj.scheme{
                case .Mastercard:
                    self.cardBenefits(cardSchemeObj)
                case .PayPak:
                    self.cardBenefits(cardSchemeObj)
                case .none:
                    print("N/A")
                }
            })
            .disposed(by: rx.disposeBag)

        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.popViewController(progress: 0.60) })
            .disposed(by: rx.disposeBag)
        
        return result
    }

    func cardScheme() -> Observable<KYCCardsSchemeM> {
        let viewController = container.makeCardSchemeViewController()
        push(viewController: viewController, progress: 0.75)
        return viewController.viewModel.outputs.next
    }
    
    func cardBenefits(_ schemeObj: KYCCardsSchemeM) {
        let viewController = container.makeCardBenefitsViewController()
        viewController.viewModel.inputs.cardSchemeMObserver.onNext(schemeObj)
        
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.navigationRoot.navigationBar.isHidden = true
        self.root.present(self.navigationRoot, animated: true, completion: nil)

        viewController.viewModel.outputs.next.subscribe(onNext: { [weak self] isPaid in
            self?.cardNamePending(schemeObj: schemeObj)
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.back.withUnretained(self).subscribe(onNext: {  _ in
            print("back button tap masterCard Benefits")
        }).disposed(by: rx.disposeBag)
    }
    
    func cardNamePending(schemeObj: KYCCardsSchemeM) {
        coordinate(to: container.makeCardNameCoordinator(root: root ,schemeObj: schemeObj, paymentGateawayM: self.paymentGateawayM))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    break
//                    if schemeObj.isPaidScheme {
//                        self?.cardDetailWebView()
//                    } else {
//                        self?.addressPending()
//                    }
                case .cancel:
                    //self?.navigationRoot.popToRootViewController(animated: true)
                    print("go back from Name")
                    break
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func addressPending() {
        coordinate(to: container.makeAddressCoordinator(root: root, paymentGateawayM: self.paymentGateawayM))
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    print("go next from address")
                case .cancel:
                    print("go back from address")
                    break
                }
            }).disposed(by: rx.disposeBag)
        
    }
    
    func cardDetailWebView() {
        let viewModel = CommonWebViewModel(container: container, repository: container.parent.makeCardsRepository())
        let viewController = container.makeCommonWebViewController(viewModel: viewModel)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            print("close in coord")
            viewController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        
        self.navigationRoot.navigationBar.isHidden = false
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.root.present(self.navigationRoot, animated: true, completion: nil)
    }
}

// MARK: Helpers
fileprivate extension CardSchemeCoordinator {
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

extension CardSchemeCoordinator {
    
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
