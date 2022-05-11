//
//  HelpAndSupportCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import YAPCardScanner

public class HelpAndSupportCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    
    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        
        let viewModel = HelpAndSupportViewModel()
        let viewController = HelpAndSupportViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
//    fileprivate func navigateToPersonalDetails() {
//        let viewModel = PersonalDetailsViewModel((self.container.accountProvider.currentAccount.map{ $0?.customer }.unwrap()), accountRepository: self.container.makeAccountRepository(), kycRepository: self.container.makeKYCRepository())
//        let viewController = PersonalDetailsViewController(viewModel: viewModel, themeService: self.container.themeService)
//
//        viewModel.outputs.editEmailTap.subscribe(onNext: { [weak self] email in
//            guard let self = self else {return}
//            self.navigateToEditEmail()
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.editPhoneTap.subscribe(onNext: { [weak self] _ in
//            guard let self = self else { return }
//            print("Edit Phone Tapped")
//            self.navigateToEditPhone()
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
//            print("Back Button Pressed on perosnal details Screen")
//            guard let self = self else { return }
//            self.localRoot.popViewController(animated: true, nil)
//        }).disposed(by: disposeBag)
//
//        let identityDocument = viewModel.outputs.scanCard.withUnretained(self)
//            .flatMap { _ in self.cnicScanOcrReview() }.elements()
//            .map{ $0.isSuccess?.identityDocument }.unwrap().share()
//
////        let identityDocument = Observable<Void>.just(()).concat(Observable.never())
////            .flatMap { _ in self.cnicScanOcrReview() }.elements()
////            .map{ $0.isSuccess?.identityDocument }.unwrap().share()
//
//        identityDocument
//            .subscribe(onNext:{ identDoc in
//                viewModel.inputs.detectOCRObserver.onNext(identDoc)
//            })
//            .disposed(by: disposeBag)
//
////        let identityScanner = viewModel.outputs.scanCard.withUnretained(self)
////            .flatMap({ profile, _ in
////                self.cnicScanOcrReview()
////            })
////
////        identityScanner
////            .subscribe(onNext: { va in
////                if let _ = va.isSuccess {
////                    viewModel.inputs.detectOCRObserver.onNext(IdentityDocument())
////                } else if va.isCancel {
////                    //Do nothing
////                }
////            })
////            .disposed(by: disposeBag)
//
//        self.localRoot.pushViewController(viewController, completion: nil)
//    }
//
////    fileprivate func navigationtoChangePasscode() {
////        ChangePasscodeCoordinator(root: self.localRoot, container: self.container)
////    }
//
//    fileprivate func navigateToEditEmail() {
//        coordinate(to: ChangeEmailAddressCoordinator(root: self.localRoot, container: self.container)).subscribe(onNext: { [weak self] result in
//            guard let _ = self else { return }
//            switch result {
//            case .success:
//                print("OTP Successfully Verified now update email")
//
//            case .cancel:
//                //                    self?.navigationRoot.popToRootViewController(animated: true)
//                print("OTP not verified")
//                break
//            }
//        }).disposed(by: rx.disposeBag)
//    }
//
//    fileprivate func navigateToEditPhone() {
//        coordinate(to: ChangePhoneNumberCoordinator(root: self.localRoot, container: self.container)).subscribe(onNext: { [weak self] result in
//            guard let _ = self else { return }
//            switch result {
//            case .success:
//                print("OTP Successfully Verified now uodate email")
//            case .cancel:
//                //                    self?.navigationRoot.popToRootViewController(animated: true)
//                print("OTP not verified")
//                break
//            }
//        }).disposed(by: rx.disposeBag)
//    }
//
//    fileprivate func cnicScanOcrReview() -> Observable<Event<ResultType<IdentityScannerResult>>> {
//        let coordn = coordinate(to: CNICReScanCoordinator(container: container, root: localRoot, scanType: .update))
//        let val = coordn.materialize()
//        return val
//    }
//
//    fileprivate func resultSuccess() {
//        // NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
//        self.container.biometricsManager.deleteBiometryForUser(phone: self.container.parent.credentialsStore.getUsername() ?? "")
//        self.container.parent.credentialsStore.clearCredentials()
//        let name = Notification.Name.init(.logout)
//        NotificationCenter.default.post(name: name,object: nil)
//    }
}

