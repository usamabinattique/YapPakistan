//
//  UserProfileCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 04/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import YAPCore

public enum UserProfileResult {
    case logout
    case other
}

public class UserProfileCoordinator: Coordinator<ResultType<Void>> {
    
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
        let viewModel: UserProfileViewModelType = UserProfileViewModel(customer: container.accountProvider.currentAccount.map{ $0?.customer }.unwrap(), biometricsManager: container.biometricsManager, credentialStore: container.parent.credentialsStore, repository: container.makeLoginRepository(), notificationManager: container.parent.makeNotificationManager())
        let viewController = UserProfileViewController(viewModel: viewModel, themeService: container.themeService)
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        
        viewController.viewModel.outputs.personalDetailsTap.subscribe(onNext: { [weak self] _ in
            print("Personal Details Button tapped in Coordinator")
            self?.navigateToPersonalDetails()
        }).disposed(by: disposeBag)
        
        viewController.viewModel.outputs.changePasscodeTap.subscribe(onNext: { [weak self] _ in
            
            print("Change passcode button tapped in coordinator")
            
            
        }).disposed(by: disposeBag)
        
        
        viewController.viewModel.outputs.result
            .withUnretained(self)
            .subscribe(onNext: {  $0.0.resultSuccess() })
            .disposed(by: rx.disposeBag)
        
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
    fileprivate func navigateToPersonalDetails() {
        let viewModel = PersonalDetailsViewModel((self.container.accountProvider.currentAccount.map{ $0?.customer }.unwrap()), accountRepository: self.container.makeAccountRepository())
        let viewController = PersonalDetailsViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        viewModel.outputs.editEmailTap.subscribe(onNext: { [weak self] email in
            guard let self = self else {return}
            self.navigateToEditEmail()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.editPhoneTap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            print("Edit Phone Tapped")
            self.navigateToEditPhone()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            print("Back Button Pressed on perosnal details Screen")
            guard let self = self else { return }
            self.localRoot.popViewController(animated: true, nil)
        }).disposed(by: disposeBag)
        
        self.localRoot.pushViewController(viewController, completion: nil)
    }
    
    fileprivate func navigateToEditEmail() {
        coordinate(to: ChangeEmailAddressCoordinator(root: self.localRoot, container: self.container)).subscribe(onNext: { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success:
                print("OTP Successfully Verified now update email")
            
            case .cancel:
//                    self?.navigationRoot.popToRootViewController(animated: true)
                print("OTP not verified")
                break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    fileprivate func navigateToEditPhone() {
        coordinate(to: ChangePhoneNumberCoordinator(root: self.localRoot, container: self.container)).subscribe(onNext: { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success:
                print("OTP Successfully Verified now uodate email")
            case .cancel:
//                    self?.navigationRoot.popToRootViewController(animated: true)
                print("OTP not verified")
                break
            }
        }).disposed(by: rx.disposeBag)
    }
    
    fileprivate func resultSuccess() {
        // NotificationCenter.default.post(name: NSNotification.Name("LOGOUT"), object: nil)
        self.container.biometricsManager.deleteBiometryForUser(phone: self.container.parent.credentialsStore.getUsername() ?? "")
        self.container.parent.credentialsStore.clearCredentials()
        let name = Notification.Name.init(.logout)
        NotificationCenter.default.post(name: name,object: nil)
    }
}

