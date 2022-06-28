//
//  CardSchemeCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import UIKit

class CardSchemeCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController
    private var localRoot: UINavigationController!
    private var navigationRoot: UINavigationController!
    private let container: UserSessionContainer
    private var paymentGatewayM: PaymentGatewayLocalModel!
    //private var cardSchemeModel: KYCCardsSchemeM!
    private var contactsManager: ContactsManager!

    init(root: UINavigationController,
         container: UserSessionContainer) {
        self.container = container
        self.root = root
        self.paymentGatewayM = PaymentGatewayLocalModel()
        super.init()
        
        self.navigationRoot = makeNavigationController()
        self.contactsManager = ContactsManager(repository: container.makeY2YRepository())
        self.navigationRoot.modalPresentationStyle = .fullScreen
    }

    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
      
        cardScheme()
            .subscribe(onNext:{ [weak self] cardSchemeObj in
                guard let `self` = self else { return }
                self.paymentGatewayM.cardSchemeObject = cardSchemeObj
                switch cardSchemeObj.scheme {
                case .Mastercard:
                    self.cardBenefits(cardSchemeObj)
                case .PayPak:
                    self.cardBenefits(cardSchemeObj)
                case .none:
                    print("N/A")
                }
            })
            .disposed(by: rx.disposeBag)
        
        return result
    }

    func cardScheme() -> Observable<KYCCardsSchemeM> {
        let viewController = container.makeCardSchemeViewController()
        
        let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(self.container.parent.themeService.attrs.primary), font: .regular)
        
        
        viewController.viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.root.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        self.localRoot = navController
        self.root.pushViewController(viewController)
        return viewController.viewModel.outputs.next
    }
    
    func cardBenefits(_ schemeObj: KYCCardsSchemeM) {
        let viewController = container.makeCardBenefitsViewController()
        viewController.viewModel.inputs.cardSchemeMObserver.onNext(schemeObj)
        
        self.localRoot.navigationBar.isHidden = true
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.navigationRoot.navigationBar.isHidden = true
        self.root.present(self.navigationRoot, animated: true, completion: nil)

        viewController.viewModel.outputs.fedValue
            .subscribe(onNext:{ fed in
                self.paymentGatewayM.cardSchemeObject?.fedFee = fed
            })
            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.subscribe(onNext: { [unowned self] isTopupNeeded in
            
            if isTopupNeeded {
                coordinate(to: AddMoneyCoordinator(root: viewController, container: self.container, contactsManager: self.contactsManager, repository: container.makeY2YRepository())).subscribe(onNext: { result in
                    
                }).disposed(by: rx.disposeBag)
            } else {
                self.cardNamePending(schemeObj: schemeObj)
            }
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.back.withUnretained(self).subscribe(onNext: {  _ in
            print("back button tap masterCard Benefits")
            self.localRoot.navigationBar.isHidden = false
            self.navigationRoot.navigationBar.isHidden = false
            self.root.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func cardNamePending(schemeObj: KYCCardsSchemeM) {
        let kycRepository = container.makeKYCRepository()
        let accountProvider = container.accountProvider
        let themeService = container.themeService

        let viewModel = CardNameViewModel(kycRepository: kycRepository, accountProvider: accountProvider, schemeObj: schemeObj)
        let viewController =  CardNameViewController(themeService: themeService, viewModel: viewModel)
        self.navigationRoot.pushViewController(viewController, animated: true)

        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.navigationRoot.popViewController()
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.next.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                guard let cardScheme = self.paymentGatewayM.cardSchemeObject else { return }
                    self.addressPending()
            })
            .disposed(by: rx.disposeBag)

        viewController.viewModel.outputs.edit.withLatestFrom(viewController.viewModel.outputs.editNameForEditNameScreen)
            .flatMap({ [unowned self] name in
                self.editName(name: name)

            }).bind(to: viewController.viewModel.inputs.nameObserver)
            .disposed(by: rx.disposeBag)
        
    }
    
    func editName(name: String) -> Observable<String> {
        let themeService = self.container.themeService
        let viewModel = EditNameViewModel(name: name)
        let viewController =  EditCardNameViewController(themeService: themeService, viewModel: viewModel)
        self.navigationRoot.pushViewController(viewController, completion: nil)
        
        viewController.viewModel.outputs.back.withUnretained(self)
            .subscribe(onNext: { `self`, _
                in
                self.navigationRoot.popViewController()
            })
            .disposed(by: rx.disposeBag)

        let next = viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in
                //self?.addressPending()
                self?.navigationRoot.popViewController()
            })
        return next
    }
    
    func addressPending() {
        let themeService = container.themeService
        let locationService = LocationService()
        let kycRepository = container.makeKYCRepository()
        let viewModel = AddressViewModel(locationService: locationService,
                                         kycRepository: kycRepository,
                                         accountProvider: container.accountProvider,
                                         configuration: container.parent.configuration)
        let viewController =  AddressViewController(themeService: themeService, viewModel: viewModel)

        self.navigationRoot.pushViewController(viewController, completion: nil)
        
        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.subscribe(onNext: { [weak self] location in
            guard let `self` = self else { return }
            self.paymentGatewayM.locationData = location
            print("next called in address")
            self.confirmPayment()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.navigationRoot.popViewController()
        }).disposed(by: rx.disposeBag)
    }
    
    func confirmPayment() {
        coordinate(to: ConfirmPaymentCoordinator(root: navigationRoot, container: container, repository: container.makeY2YRepository(), shouldPresent: true, paymentGatewayM: paymentGatewayM))
            .subscribe(onNext: { [unowned self] result in
            switch result {
            case .success:
                self.root.dismiss(animated: true)
                self.moveNext()
            case .cancel:
                ()
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()
        let navigation = container.makeNavigationController(root: viewController)
        
        navigationRoot.present(navigation, animated: true)
        
        viewController.viewModel.outputs.back
             .subscribe(onNext: { [weak self] _ in
                 viewController.dismiss(animated: true)
             })
             .disposed(by: rx.disposeBag)

         return viewController.viewModel.outputs.next
             .do(onNext: { [weak self] _ in
                 viewController.dismiss(animated: true)
             })
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
