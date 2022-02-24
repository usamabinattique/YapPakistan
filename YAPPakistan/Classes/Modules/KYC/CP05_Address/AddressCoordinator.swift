//
//  AddressCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/11/2021.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

class AddressCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private var localRoot: UINavigationController!
    private let container: KYCFeatureContainer
    private var paymentGatewayM: PaymentGatewayLocalModel!
    private var confirmPaymentCreated = 0
    private var isPresented: Bool

    init(root: UINavigationController,
         container: KYCFeatureContainer, paymentGatewayM: PaymentGatewayLocalModel, isPresented: Bool = false) {
        self.container = container
        self.root = root
        self.paymentGatewayM = paymentGatewayM
        self.isPresented = isPresented
        
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let progressRoot = container.makeKYCProgressViewController()
       // root.pushViewController(progressRoot)
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        localRoot.setNavigationBarHidden(true, animated: false)
        localRoot.pushViewController(progressRoot)
        
        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.goBack()
                if self.isPresented {
                    self.localRoot.dismiss(animated: true, completion: nil)
                } else {
                    self.root.popViewController()
                }
                
                
            })
            .disposed(by: rx.disposeBag)
        progressRoot.hidesBottomBarWhenPushed = true

        let viewController = container.makeAddressViewController()
        
        push(viewController: viewController, progress: 0.90)
        //root.present(localRoot, animated: true, completion: nil)
        //localRoot.present(localRoot, animated: true, completion: nil)
        root.present(localRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.subscribe(onNext: { [weak self] location in
            guard let `self` = self, self.confirmPaymentCreated < 1 else { return }
            self.confirmPaymentCreated = self.confirmPaymentCreated + 1
            self.paymentGatewayM.locationData = location
            print("next called in address")
            self.confirmPayment().subscribe(onNext: { [weak self] value in
                guard let `self` = self else { return }
                print("confirm called in address")
                switch value {
                case .cancel:
                    self.confirmPaymentCreated = 0
                case .success(_):
                    if self.isPresented {
                        self.localRoot.dismiss(animated: true) {
                            self.kycResult()
                        }
                    } else {
                        self.root.popViewController()
                        self.kycResult()
                    }
                    print("success")
                }
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        return result
    }

    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()
        let navigation = container.makeNavigationController(root: viewController)
       // root.present(navigation, animated: true)
        localRoot.present(navigation, animated: true)

       /* viewController.viewModel.outputs.back
            .subscribe(onNext: { [weak self] _ in self?.root.dismiss(animated: true) })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.root.dismiss(animated: true) }) */
        
        viewController.viewModel.outputs.back
             .subscribe(onNext: { [weak self] _ in viewController.dismiss(animated: true) })
             .disposed(by: rx.disposeBag)

         return viewController.viewModel.outputs.next
             .do(onNext: { [weak self] _ in viewController.dismiss(animated: true) })
    }
    
    func kycResult() {
        coordinate(to: KYCResultCoordinator(root: root, container: container))
            .subscribe(onNext:{ [weak self] result in
                switch result {
                case .success:
                    print("go next from Name address")
                    self?.goToHome()
                case .cancel:
//                    self?.navigationRoot.popToRootViewController(animated: true)
                    print("go back from Name address")
                    break
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func confirmPayment() -> Observable<ResultType<Void>> {
       /* return coordinate(to: ConfirmPaymentCoordinator(root: root, container: container, repository: container.makeY2YRepository(), shouldPresent: true,paymentGatewayM: paymentGatewayM)) */
        return coordinate(to: ConfirmPaymentCoordinator(root: localRoot, container: container, repository: container.makeY2YRepository(), shouldPresent: true,paymentGatewayM: paymentGatewayM))
    }
    
  /*  func navigateToCVV(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String) {
        let viewModel = TopupCardCVVViewModel(card: card, amount: amount, currency: currency, orderID: orderID, threeDSecureId: threeDSecureId)
        let viewController = TopupCardCVVViewController(themeService: container.themeService, viewModel: viewModel)
      //  root.setNavigationBarHidden(false, animated: false)
      /*  self.root.pushViewController(viewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.root.setNavigationBarHidden(false, animated: false)
            }
           
        }//present(navigationRoot, animated: true, completion: nil) */
        self.localRoot.pushViewController(viewController) {
             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 self.localRoot.setNavigationBarHidden(false, animated: false)
             }
            
         }
        
//        navigationController.navigationBar.isHidden = false
//        navigationController.pushViewController(viewController, animated: true)
        
       /* viewModel.outputs.result.subscribe(onNext: { [weak self] _ in
            self?.root.setNavigationBarHidden(true, animated: false)
           // self?.navigateToTopupSuccess(amount: $0.amount, currency: $0.currency, card: $0.card, navigationController: navigationController)
            //TODO: remove following line
            self?.goToHome()
        }).disposed(by: rx.disposeBag) */
        viewModel.outputs.result.subscribe(onNext: { [weak self] _ in
             self?.localRoot.setNavigationBarHidden(true, animated: false)
            // self?.navigateToTopupSuccess(amount: $0.amount, currency: $0.currency, card: $0.card, navigationController: navigationController)
             //TODO: remove following line
             self?.goToHome()
         }).disposed(by: rx.disposeBag)
        
       /* viewModel.outputs.backObservable.subscribe(onNext: { [weak self] _ in
            self?.root.setNavigationBarHidden(true, animated: false)
            self?.root.popViewController()
        }).disposed(by: rx.disposeBag)  */
        viewModel.outputs.backObservable.subscribe(onNext: { [weak self] _ in
            self?.localRoot.setNavigationBarHidden(true, animated: false)
            self?.localRoot.popViewController()
        }).disposed(by: rx.disposeBag)
    } */
    
    func goToHome() {
     //   self.root.popToRootViewController(animated: true)
        self.localRoot.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

// MARK: Helpers
fileprivate extension AddressCoordinator {
    var progressRoot: KYCProgressViewController! { localRoot.topViewController as? KYCProgressViewController } //root.topViewController as? KYCProgressViewController }

    func push(viewController: UIViewController, progress: Float ) {
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.pushViewController(viewController, animated: true)
    }

    func popViewController(progress: Float) {
//        guard self.progressRoot.childNavigation.viewControllers.count > 1 else {
//            return goBack()
//        }
        self.progressRoot.viewModel.inputs.progressObserver.onNext(progress)
        self.progressRoot.childNavigation.popViewController(animated: true)
    }
    
    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }
}
