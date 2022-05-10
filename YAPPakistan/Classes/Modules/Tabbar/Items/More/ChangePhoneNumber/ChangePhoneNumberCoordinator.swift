//
//  ChangePhoneNumberCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 13/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import YAPCore

public class ChangePhoneNumberCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    private let otpResult = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    private var isOTPPresented = false
    
    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = ChangePhoneNumberViewModel(otpRepository: self.container.makeOTPRepository())
        let viewController = ChangePhoneNumberViewController(viewModel: viewModel, themeService: self.container.themeService)
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)

        viewModel.outputs.next.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            viewModel.outputs.phoneNumberTextfield.subscribe(onNext: { [unowned self] newPhone in
                let newPhoneNumber = newPhone
                if !self.isOTPPresented {
                    self.isOTPPresented = true
                    self.otp(.changeMobileNumber, mobileNo: newPhoneNumber)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.localRoot.dismiss(animated: true, completion: nil)
            self.isOTPPresented = false
        }).disposed(by: disposeBag)

        viewModel.outputs.success.subscribe(onNext: { [unowned self] mobileNumber in
            self.navigateToChangeEmailSuccess(phoneNumber: mobileNumber)
        }).disposed(by: disposeBag)
        
        self.otpResult.subscribe(onNext: { [unowned self] _ in
            viewModel.inputs.changePhoneNumberRequestObserver.onNext(())
        }).disposed(by: disposeBag)

        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
    func navigateToChangeEmailSuccess(phoneNumber: String) {
        let viewModel = UnvarifiedEmailSuccessViewModel(changedEmailOrPhoneString: "", descriptionText: "screen_phone_number_update_success")
        let viewController = UnvarifiedEmailSuccessViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        
        viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.localRoot.dismiss(animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
        
        localRoot.pushViewController(viewController, completion: nil)
    }
    
    func otp(_ action: OTPAction, mobileNo : String) {
        let formattedPhoneNumber = mobileNo.replacePrefix("+", with: "00").removeWhitespace()
        let subHeadingText = String(format: "screen_add_beneificiary_otp_display_text_sub_heading".localized, formattedPhoneNumber)
        let viewModel = VerifyMobileOTPViewModel(action: action, heading: "screen_add_beneificiary_otp_display_text_heading".localized, subheading: subHeadingText , repository: container.makeOTPRepository(), mobileNo: formattedPhoneNumber, passcode: "" , backButtonImage: .backEmpty)
        let viewController = VerifyMobileOTPViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            print("OPT: Back Button Pressed")
            self.isOTPPresented = false
            self.localRoot.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.validOTPSuccess.subscribe(onNext: { [unowned self] isOTPValid in
            print("Chnage Phone Number Coordinator Called with OTP Valid: \(isOTPValid)")
            if isOTPValid {
                self.otpResult.onNext(ResultType.success(()))
            }
        }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, completion: nil)
    }
}
