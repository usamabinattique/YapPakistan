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
    private let container: UserSessionContainer
    private var paymentGatewayM: PaymentGatewayLocalModel!
    private var isPresented: Bool

    init(root: UINavigationController,
         container: UserSessionContainer, paymentGatewayM: PaymentGatewayLocalModel, isPresented: Bool = false) {
        self.container = container
        self.root = root
        self.paymentGatewayM = paymentGatewayM
        self.isPresented = isPresented
        
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
       
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        localRoot.setNavigationBarHidden(true, animated: false)
        
        let viewController = container.makeAddressViewController()
        
        localRoot.pushViewController(viewController)
        //root.present(localRoot, animated: true, completion: nil)
        //localRoot.present(localRoot, animated: true, completion: nil)
        root.present(localRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.city.withUnretained(self)
            .flatMap{ `self`, _ in self.selectCityName() }
            .bind(to: viewController.viewModel.inputs.citySelectObserver)
            .disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.next.subscribe(onNext: { [weak self] location in
            guard let `self` = self else { return }
            self.paymentGatewayM.locationData = location
            print("next called in address")
            self.confirmPayment().subscribe(onNext: { [weak self] value in
                guard let `self` = self else { return }
                print("confirm called in address")
                switch value {
                case .cancel:
                    print("confirm payment cancel ")
                case .success(_):
                    if self.isPresented {
                        self.localRoot.dismiss(animated: true) {
                            //self.kycResult()
                            self.root.dismiss(animated: true)
                        }
                    } else {
                        self.root.popViewController()
                        //self.kycResult()
                        self.root.dismiss(animated: true)
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
    
    func confirmPayment() -> Observable<ResultType<Void>> {
       /* return coordinate(to: ConfirmPaymentCoordinator(root: root, container: container, repository: container.makeY2YRepository(), shouldPresent: true,paymentGatewayM: paymentGatewayM)) */
        return coordinate(to: ConfirmPaymentCoordinator(root: localRoot, container: container, repository: container.makeY2YRepository(), shouldPresent: false, paymentGatewayM: paymentGatewayM))
    }
    
    func goToHome() {
     //   self.root.popToRootViewController(animated: true)
        self.localRoot.popToRootViewController(animated: true)
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }
}

// MARK: Helpers
fileprivate extension AddressCoordinator {
    
    func moveNext() {
        self.result.onNext(.success(()))
        self.result.onCompleted()
    }

    func goBack() {
        self.result.onNext(.cancel)
        self.result.onCompleted()
    }
}
