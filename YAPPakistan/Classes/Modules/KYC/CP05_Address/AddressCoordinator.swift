//
//  AddressCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 20/11/2021.
//

import Foundation
import RxSwift
import YAPCore

class AddressCoordinator: Coordinator<ResultType<Void>> {

    private let result = PublishSubject<ResultType<Void>>()
    private let root: UINavigationController!
    private let container: KYCFeatureContainer
    private var paymentGateawayM: PaymentGateawayLocalModel!

    init(root: UINavigationController,
         container: KYCFeatureContainer, paymentGateawayM: PaymentGateawayLocalModel) {
        self.container = container
        self.root = root
        self.paymentGateawayM = paymentGateawayM
        
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let progressRoot = container.makeKYCProgressViewController()
        root.pushViewController(progressRoot)
        
        progressRoot.viewModel.outputs.backTap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.goBack()
                self.root.popViewController()
            })
            .disposed(by: rx.disposeBag)
        progressRoot.hidesBottomBarWhenPushed = true

        let viewController = container.makeAddressViewController()
        push(viewController: viewController, progress: 0.90)

        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)

    /*    viewController.viewModel.outputs.next.withUnretained(self)
            .flatMap({  _ in self.confirmPayment()
            }).withUnretained(self).subscribe(onNext: { `self`, value in
                switch value {
                case .cancel:
                    break
                case .success(_):
                    //TODO: add proper CVV dependencies here
                    self.navigateToCVV(card: ExternalPaymentCard.mock, amount: 100.0, currency: "PKR", orderID: "1", threeDSecureId: "1")
                }
                
            }).disposed(by: rx.disposeBag) */
        
        //TODO: connect flow properly
        /// for paypak flow
        viewController.viewModel.outputs.next.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            print("next called in address")
            self.confirmPayment().subscribe(onNext: { [weak self] value in
                guard let `self` = self else { return }
                print("confrim called in address")
                switch value {
                case .cancel:
                    break
                case .success(_):
                    //TODO: add proper CVV dependencies here
                    self.navigateToCVV(card: ExternalPaymentCard.mock, amount: 100.0, currency: "PKR", orderID: "1", threeDSecureId: "1")
                }
               
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        return result
    }

    func selectCityName() -> Observable<String>  {
        let viewController = container.makeCityListViewController()
        let navigation = container.makeNavigationController(root: viewController)
        root.present(navigation, animated: true)

        viewController.viewModel.outputs.back
            .subscribe(onNext: { [weak self] _ in self?.root.dismiss(animated: true) })
            .disposed(by: rx.disposeBag)

        return viewController.viewModel.outputs.next
            .do(onNext: { [weak self] _ in self?.root.dismiss(animated: true) })
    }
    
    func kycResult() -> Observable<ResultType<Void>> {
        return coordinate(to: KYCResultCoordinator(root: root, container: container))
    }
    
    func confirmPayment() -> Observable<ResultType<Void>> {
        return coordinate(to: ConfirmPaymentCoordinator(root: root, container: container.parent, repository: container.makeY2YRepository(), shouldPresent: true, paymentGateawayM: self.paymentGateawayM))
    }
    
    func navigateToCVV(card: ExternalPaymentCard, amount: Double, currency: String, orderID: String, threeDSecureId: String) {
        let viewModel = TopupCardCVVViewModel(card: card, amount: amount, currency: currency, orderID: orderID, threeDSecureId: threeDSecureId)
        let viewController = TopupCardCVVViewController(themeService: container.themeService, viewModel: viewModel)
      //  root.setNavigationBarHidden(false, animated: false)
        self.root.pushViewController(viewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.root.setNavigationBarHidden(false, animated: false)
            }
           
        }//present(navigationRoot, animated: true, completion: nil)
        
//        navigationController.navigationBar.isHidden = false
//        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] _ in
            self?.root.setNavigationBarHidden(true, animated: false)
           // self?.navigateToTopupSuccess(amount: $0.amount, currency: $0.currency, card: $0.card, navigationController: navigationController)
            //TODO: remove following line
            self?.goToHome()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.backObservable.subscribe(onNext: { [weak self] _ in
            self?.root.setNavigationBarHidden(true, animated: false)
            self?.root.popViewController()
        }).disposed(by: rx.disposeBag)
    }
    
    func goToHome() {
        self.root.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

// MARK: Helpers
fileprivate extension AddressCoordinator {
    var progressRoot: KYCProgressViewController! { root.topViewController as? KYCProgressViewController }

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
