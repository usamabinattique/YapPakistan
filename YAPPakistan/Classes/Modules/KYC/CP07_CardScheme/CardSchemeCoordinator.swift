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

    init(root: UINavigationController,
         container: KYCFeatureContainer) {
        self.container = container
        self.root = root
        
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
                switch cardSchemeObj.scheme{
                case .Mastercard:
                    self.masterCardBenefits(cardSchemeObj)
                    
                case .PayPak:
                    print("PayPak -> navigation flow")
                case .none:
                    print("N/A")
                }
            })
            .disposed(by: rx.disposeBag)

        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.popViewController(progress: 0.25) })
            .disposed(by: rx.disposeBag)
        
        return result
    }

    func cardScheme() -> Observable<KYCCardsSchemeM> {
        let viewController = container.makeCardSchemeViewController()
        push(viewController: viewController, progress: 0.25)
        return viewController.viewModel.outputs.next
    }
    
    func masterCardBenefits(_ schemeObj: KYCCardsSchemeM) -> Observable<CardBenefitsViewController> {
        let viewController = container.makeMasterCardBenefitsViewController()
        viewController.viewModel.inputs.cardSchemeMObserver.onNext(schemeObj)
        
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.navigationRoot.navigationBar.isHidden = true
        self.root.present(self.navigationRoot, animated: true, completion: nil)

        viewController.viewModel.outputs.next.withUnretained(self).subscribe(onNext: {  _ in
            self.cardNamePending()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.back.withUnretained(self).subscribe(onNext: {  _ in
            print("back button tap masterCard Benefits")
        }).disposed(by: rx.disposeBag)

        
        return Observable.just(viewController)
    }
    
    func PayPakCardBenefits(_ schemeObj: KYCCardsSchemeM) -> Observable<CardBenefitsViewController> {
        let viewController = container.makeMasterCardBenefitsViewController()
        viewController.viewModel.inputs.cardSchemeMObserver.onNext(schemeObj)
        
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.navigationRoot.navigationBar.isHidden = true
        self.root.present(self.navigationRoot, animated: true, completion: nil)

        viewController.viewModel.outputs.next.withUnretained(self).subscribe(onNext: {  _ in
            self.cardNamePending()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.back.withUnretained(self).subscribe(onNext: {  _ in
            print("back button tap masterCard Benefits")
        }).disposed(by: rx.disposeBag)

        
        return Observable.just(viewController)
    }
    
    func cardNamePending() -> Observable<ResultType<Void>> {
        return coordinate(to: container.makeCardNameCoordinator(root: root))
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
