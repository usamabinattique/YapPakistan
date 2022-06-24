//
//  KYCReviewCoordinator.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import YAPCardScanner
import Foundation
import RxSwift
import YAPCore

class KYCReviewCoordinator : Coordinator<ResultType<Void>> {
    private let container: KYCFeatureContainer
    private let root: UINavigationController!
    private let identityDocument: IdentityDocument
    private let cnicOCR: CNICOCR
    
    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let disposeBag = DisposeBag()
    
    init(container: KYCFeatureContainer,
         root: UINavigationController,
         identityDocument: IdentityDocument,
         cnicOCR: CNICOCR) {
        self.container = container
        self.root = root
        self.identityDocument = identityDocument
        self.cnicOCR = cnicOCR
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let reviewViewController = container.makeKYCInitialReviewViewController(cnicOCR: cnicOCR)
        let reviewViewModel = reviewViewController.viewModel
        
        reviewViewModel.outputs.rescan
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.outputs.cnicInfo
            .subscribe(onNext: { [weak self] cnicInfo in
                guard let self = self else { return }
                self.navigateToReviewDetails(cnicOCR: self.cnicOCR, cnicInfo: cnicInfo)
            })
            .disposed(by: disposeBag)
        
        let navigationController = UINavigationController(rootViewController: reviewViewController)
        navigationController.navigationBar.isHidden = true
        
        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel
        progressViewModel.inputs.progressObserver.onNext(0.25)
        
        root.pushViewController(progressViewController, animated: true)
        
        progressViewModel.outputs.backTap
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.cancel)
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)
        
        return resultSubject
    }
    
    private func navigateToReviewDetails(cnicOCR: CNICOCR, cnicInfo: CNICInfo) {
        let reviewViewController = container.makeKYCReviewDetailsViewController(
            identityDocument: identityDocument, cnicOCR: cnicOCR, cnicInfo: cnicInfo)
        let reviewViewModel = reviewViewController.viewModel
        
        reviewViewModel.outputs.next
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(.success(()))
                self?.resultSubject.onCompleted()
            })
            .disposed(by: disposeBag)
        
        reviewViewModel.outputs.cnicBlockCase.subscribe(onNext: { [unowned self] cnicBlockCase in
            self.navigateToCNICBlockCaseErrorViewController(cnicBlockCase: cnicBlockCase)
        }).disposed(by: rx.disposeBag)
        
        let navigationController = UINavigationController(rootViewController: reviewViewController)
        navigationController.navigationBar.isHidden = true
        
        let progressViewController = container.makeKYCProgressViewController(navigationController: navigationController)
        let progressViewModel: KYCProgressViewModelType! = progressViewController.viewModel
        progressViewModel.inputs.progressObserver.onNext(0.50)
        
        root.pushViewController(progressViewController, animated: true)
        
        progressViewModel.outputs.backTap
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToCNICBlockCaseErrorViewController(cnicBlockCase: CNICBlockCase) {
        let viewModel = CNICBlockCaseErrorViewModel(cnicBlockCase: cnicBlockCase)
        let viewController = CNICBlockCaseErrorViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.actionButton.subscribe(onNext: { [weak self] blockCase in
            guard let self = self else { return }
            
            if blockCase == nil { return }
            
            if blockCase == .underAge {
                // Perform Logout here
                self.perfromLogout()
            }
            else if blockCase == .invalidCNIC {
                // Perform Rescan CNIC here
                self.root.popViewController(animated: true, nil)
                self.root.popViewController(animated: true, nil)
            }
            else if blockCase == .cnicExpiredOnScane {
                // Perform Rescan CNIC here
                //self.navigateToRescanCNIC()
                self.root.popViewController(animated: true, nil)
                self.root.popViewController(animated: true, nil)
            }
            else if blockCase == .cnicAlreadyUsed {
                // Perform Logout here
                self.perfromLogout()
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.gotoDashboard.subscribe(onNext: { [weak self] _ in
            self?.root.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
        
        root.pushViewController(viewController, completion: nil)
    }
    
    func navigateToRescanCNIC() {
        coordinate(to: CNICScanCoordinator(container: container, root: self.root, scanType: .new)).subscribe(onNext: { result in
            print(result)
            
            //self.navigateToReviewDetails(cnicOCR: self.cnicOCR, cnicInfo: result)
            
        }).disposed(by: self.disposeBag)
    }
    
    func perfromLogout() {
        self.container.parent.biometricsManager.deleteBiometryForUser(phone: self.container.parent.parent.credentialsStore.getUsername() ?? "")
        if !(self.container.parent.parent.credentialsStore.remembersId ?? false) {
            self.container.parent.parent.credentialsStore.clearCredentials()
        }
        
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
    }
}
