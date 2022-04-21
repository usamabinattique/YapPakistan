//
//  ChangeEmailAddressCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 12/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import YAPCore


public class ChangeEmailAddressCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    private let otpResult = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = ChangeEmailAddressViewModel( otpRepository: self.container.makeOTPRepository(), accountRepository: self.container.makeAccountRepository())
        let viewController = ChangeEmailAddressViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        
        
        viewModel.outputs.next.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.otp(.changeEmail)
        }).disposed(by: disposeBag)
        
        // OTP Success result
        self.otpResult.subscribe(onNext: { result in
            if case ResultType.success(()) = result {
                viewModel.inputs.changeEmailRequestObserver.onNext(())
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            print("Back btn Pressed On Change Email Coordinator")
            self.localRoot.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
        viewModel.outputs.success.subscribe(onNext: { [unowned self] emailString in
            
            print("jjj")
            self.navigateToChangeEmailSuccess(email: emailString)
            
        }).disposed(by: disposeBag)
        
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
    func navigateToChangeEmailSuccess(email: String) {
        let viewModel = UnvarifiedEmailSuccessViewModel(changedEmailOrPhoneString: email, descriptionText: "")
        let viewController = UnvarifiedEmailSuccessViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        
        viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.localRoot.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, completion: nil)
    }
    
    func otp(_ action: OTPAction) {
        
        
        let countryCode = container.accountProvider.currentAccountValue.value?.customer.countryCode ?? "" //""
        let mobileNumber = container.accountProvider.currentAccountValue.value?.customer.mobileNo ?? "" //""
        let formattedPhoneNumber: String = countryCode + mobileNumber
       
       
        let subHeadingText = String(format: "screen_add_beneificiary_otp_display_text_sub_heading".localized, formattedPhoneNumber)
        let viewModel = VerifyMobileOTPViewModel(action: action, heading: "screen_add_beneificiary_otp_display_text_heading".localized, subheading: subHeadingText, otpTime: 60 , repository: container.makeOTPRepository(), mobileNo: formattedPhoneNumber, passcode: "" , backButtonImage: .backEmpty)
        let viewController = VerifyMobileOTPViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            print("OPT: Back Button Pressed")
            self.localRoot.popViewController(animated: true)
            
        }).disposed(by: disposeBag)
        
        viewModel.outputs.validOTPSuccess.subscribe(onNext: { [weak self] isValid in
            guard let self = self else { return }
            print("OTP Validated: \(isValid)")
            if isValid {
                //self.result.onNext(.success(()))
                self.localRoot.popViewController(animated: true, nil)
                self.otpResult.onNext(ResultType.success(()))
            }
            else {
                
            }
        }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, completion: nil)
        
        
        
        
//        let viewModel = VerifyMobileOTPViewModel(action: action, beneficiary: nil, heading: NSAttributedString(string: "screen_add_beneificiary_otp_display_text_heading".localized), subheading: NSAttributedString(string: String.init(format: "screen_add_beneificiary_otp_display_text_sub_heading".localized, String.format(phoneNumber: countryCode + mobileNumber))), backButtonImage: .closeCircled)
//        let viewController = VerifyMobileOTPViewController(viewModel: viewModel)
//
//        let nav = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
//
//        root.present(nav, animated: true, completion: nil)
//
//        var otpSubscriptions = [Disposable]()
//
//        let result = viewModel.outputs.result
//            .map{ _ in ResultType<Void>.success(()) }
//            .subscribe(onNext: { [weak self] in
//                nav.dismiss(animated: true, completion: nil)
//                self?.otpResult.onNext($0)
//            })
//
//        let back = viewModel.outputs.back
//            .map{ ResultType<Void>.cancel }
//            .subscribe(onNext: { [weak self] in
//                nav.dismiss(animated: true, completion: nil)
//                self?.otpResult.onNext($0)
//            })
//
//        otpSubscriptions.append(result)
//        otpSubscriptions.append(back)
//
//        otpResult.subscribe(onNext: { _ in otpSubscriptions.forEach{ $0.dispose() } }).disposed(by: disposeBag)
    }
    
}
