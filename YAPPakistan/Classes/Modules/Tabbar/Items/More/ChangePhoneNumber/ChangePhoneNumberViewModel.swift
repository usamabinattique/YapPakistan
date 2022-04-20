//
//  ChangePhoneNumberViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 13/04/2022.
//

import Foundation
import YAPComponents
import RxSwift

import PhoneNumberKit

typealias PhoneNumberVerificationDataProvider = (heading: NSAttributedString, subHeading: NSAttributedString, action: OTPAction, mobileNo: String)

protocol ChangePhoneNumberViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var phoneNumberTextFieldObserver: AnyObserver<String> { get }
    var changePhoneNumberRequestObserver: AnyObserver<Void> { get }
}

protocol ChangePhoneNumberViewModelOutputs {
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var success: Observable<String> { get }
    var text: Observable<NSAttributedString?> { get }
    var inputValidation: Observable<PhoneNumberView.ValidationState> { get }
    var back: Observable<Void> { get }
    var next: Observable<Void> { get }
    var heading: Observable<String?> { get }
    var phoneNumberTextFieldTitle: Observable<String?> { get }
    var nextButtonTitle: Observable<String?> { get }
    var phoneNumberTextfield: Observable<String> { get }
    var countryCode: Observable<String?> { get }
    var activateAction: Observable<Bool> { get }
    var otpGeneration: Observable<PhoneNumberVerificationDataProvider> { get }
    var changePhoneNumberRequest: Observable<Void> { get }

}

protocol ChangePhoneNumberViewModelType {
    var inputs: ChangePhoneNumberViewModelInputs { get }
    var outputs: ChangePhoneNumberViewModelOutputs { get }
}

class ChangePhoneNumberViewModel: ChangePhoneNumberViewModelType, ChangePhoneNumberViewModelInputs, ChangePhoneNumberViewModelOutputs {

    var inputs: ChangePhoneNumberViewModelInputs { return self }
    var outputs: ChangePhoneNumberViewModelOutputs { return self }

    private let loadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<String>()
    private let backSubject = PublishSubject<Void>()
    private let nextSubject = PublishSubject<Void>()
    private let phoneNumberTextFieldSubject = BehaviorSubject<String>(value: "")
    private let headingSubject: BehaviorSubject<String?>
    private let nextButtonTitleSubject: BehaviorSubject<String?>
    private let phoneNumberTextFieldTitleSubject: BehaviorSubject<String?>
    private let validationSubject = BehaviorSubject<PhoneNumberView.ValidationState>(value: .normal)
    private let textSubject = BehaviorSubject<NSAttributedString?>(value: NSAttributedString(string: ""))
    private let countryCodeSubject = BehaviorSubject<String?>(value: "+92 ")
    private let activateActionSubject = PublishSubject<Bool>()
    private let successSubject = PublishSubject<String>()
    private let otpGenerationSubject = PublishSubject<PhoneNumberVerificationDataProvider>()
    private let changePhoneNumberRequestSubject = PublishSubject<Void>()

    //inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { return nextSubject.asObserver() }
    var phoneNumberTextFieldObserver: AnyObserver<String> { return phoneNumberTextFieldSubject.asObserver() }
    var changePhoneNumberRequestObserver: AnyObserver<Void> { return changePhoneNumberRequestSubject.asObserver() }

    //outputs
    var error: Observable<String> { return errorSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var success: Observable<String> { return successSubject.asObservable() }
    var inputValidation: Observable<PhoneNumberView.ValidationState> { return validationSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var next: Observable<Void> { return nextSubject.asObservable() }
    var heading: Observable<String?> { return headingSubject.asObservable() }
    var phoneNumberTextFieldTitle: Observable<String?> { return phoneNumberTextFieldTitleSubject.asObservable() }
    var nextButtonTitle: Observable<String?> { return nextButtonTitleSubject.asObservable() }
    var phoneNumberTextfield: Observable<String> { return phoneNumberTextFieldSubject.asObservable() }
    var text: Observable<NSAttributedString?> { return textSubject.asObservable() }
    var countryCode: Observable<String?> { return countryCodeSubject.asObservable() }
    var activateAction: Observable<Bool> { return activateActionSubject.asObservable() }
    var otpGeneration: Observable<PhoneNumberVerificationDataProvider> { return otpGenerationSubject.asObservable() }
    var changePhoneNumberRequest: Observable<Void> { return changePhoneNumberRequestSubject.asObservable() }

    // MARK:- Properties
    private let phoneNumberKit = PhoneNumberKit()
    private let disposeBag = DisposeBag()
    private let otpRepository: OTPRepositoryType
//    private let profileRepository: ProfileRepository = ProfileRepository()
//    private let credentialsManager: CredentialsManager = CredentialsManager()

    public init(otpRepository: OTPRepositoryType) {
        self.otpRepository = otpRepository
        headingSubject = BehaviorSubject(value:  "screen_change_phone_number_display_text_heading".localized)
        nextButtonTitleSubject = BehaviorSubject(value:  "common_button_next".localized)
        phoneNumberTextFieldTitleSubject = BehaviorSubject(value:  "screen_change_phone_number_display_text_text_field_title".localized)
        let formattedText = phoneNumberTextFieldSubject.map { [unowned self] in self.formatePhoneNumber($0)}
        formattedText.map { $0.formatted ? .valid : .normal }.bind(to: validationSubject).disposed(by: disposeBag)
        formattedText.map { [unowned self] in self.attributed(text: $0.phoneNumber) }.bind(to: textSubject).disposed(by: disposeBag)

        inputValidation.map { if $0 == .invalid { return false } else if $0 == .valid { return true} else { return false } }.bind(to: activateActionSubject).disposed(by: disposeBag)

        changeMobileNo()
        checkPhoneNumberUniqueness()
    }
}

extension ChangePhoneNumberViewModel {

    fileprivate func checkPhoneNumberUniqueness() {

//        let validateMobileNumberRequest = next.withLatestFrom(Observable.combineLatest(phoneNumberTextFieldSubject, countryCodeSubject.unwrap())).share()
//
//        validateMobileNumberRequest.map { _ in true }.bind(to: loadingSubject).disposed(by: disposeBag)
//
//        let validateMobileNumber = validateMobileNumberRequest.flatMap { [unowned self] argv -> Observable<Event<String?>> in
//            return self.profileRepository.checkPhoneNumberUniqueness(phone: argv.0.replacingOccurrences(of: argv.1, with: "").removeWhitespace(), countryCode: argv.1.replacingOccurrences(of: "+", with: "00").trimmingCharacters(in: .whitespaces))
//        }.share()
//
//        validateMobileNumber
//            .map { _ in false }
//            .bind(to: loadingSubject)
//            .disposed(by: disposeBag)
//
//        validateMobileNumber
//            .elements()
//            .withLatestFrom(phoneNumberTextFieldSubject)
//            .map { [unowned self] phone in
//                let data: PhoneNumberVerificationDataProvider = (heading: NSAttributedString(string:  "screen_phone_number_verification_display_text_heading".localized), subHeading: NSAttributedString(string: String(format:  "screen_phone_number_verification_display_text_sub_heading".localized, self.formatePhoneNumber(phone).phoneNumber)), action: .changeMobileNumber, mobileNo: try self.format(phonenumber: phone.removeWhitespace()))
//                return data
//        }.bind(to: otpGenerationSubject)
//            .disposed(by: disposeBag)
//
//        validateMobileNumber
//            .errors()
//            .map { $0.localizedDescription }
//            .do(onNext: { [unowned self] _ in self.validationSubject.onNext(.invalid) })
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)

    }

    fileprivate func changeMobileNo() {

        let request =  changePhoneNumberRequest.withLatestFrom(Observable.combineLatest(phoneNumberTextFieldSubject, countryCodeSubject.unwrap())).share()
        
        
        request.subscribe(onNext: { [unowned self] phoneValue in
            print(phoneValue)
            
            let formattedCountryCode: String = phoneValue.1.replacePrefix("+", with: "00").removeWhitespace()
            let formattedMobileNumberArray = phoneValue.0.split(separator: " ")
            let formattedPhoneNumber = formattedMobileNumberArray[1] + formattedMobileNumberArray[2]
            let updateMobileNumberReq = self.otpRepository.updateMobileNumber(countryCode: formattedCountryCode, mobileNumber: String(formattedPhoneNumber))
            
            
            let error = updateMobileNumberReq.errors().map{ $0.localizedDescription }
            error
                .bind(to: errorSubject).disposed(by: disposeBag)
                
            updateMobileNumberReq.elements().subscribe(onNext: { data in
                
                //self.successSubject.onNext(emailString)
                print(data)
                
            }).disposed(by: disposeBag)
        })
        
//        request.map { _ in true }.bind(to: loadingSubject).disposed(by: disposeBag)
//
//        let result = request.flatMap { [unowned self] argv -> Observable<Event<Int?>> in
//            return self.profileRepository.changePhoneNumber(phone: argv.0.replacingOccurrences(of: argv.1, with: "").removeWhitespace(), countryCode: argv.1.replacingOccurrences(of: "+", with: "00").trimmingCharacters(in: .whitespaces))
//        }.share()
//
//        result
//            .map { _ in false }
//            .bind(to: loadingSubject)
//            .disposed(by: disposeBag)
//
//        result
//            .elements()
//            .withLatestFrom(phoneNumberTextFieldSubject)
//            .do(onNext: { [unowned self] in
//                guard let oldUserName = self.credentialsManager.getUsername() else { return }
//                guard let passcode = self.credentialsManager.getPasscode(username: oldUserName) else { return }
//                var newUsername = $0
//                if let phone = try? self.phoneNumberKit.parse(newUsername) {
//                    newUsername = self.phoneNumberKit.format(phone, toType: .national).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//                    newUsername = newUsername.hasPrefix("0") ? newUsername.subString(1, length: newUsername.count) : newUsername
//                }
//                self.credentialsManager.secureCredentials(username: newUsername, passcode: passcode)
//            })
//            .bind(to: successSubject)
//            .disposed(by: disposeBag)
//
//        result
//            .errors()
//            .map { $0.localizedDescription }
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
//
//        result
//            .errors()
//            .map { _ in
//                PhoneNumberView.ValidationState.invalid
//            }
//            .bind(to: validationSubject)
//            .disposed(by: disposeBag)
//
//        Observable.combineLatest(result.elements(), SessionManager.current.currentAccount.unwrap(), phoneNumberTextfield).skip(1).subscribe(onNext: { [unowned self] (_, account, text) in
//            let biometricManager = BiometricsManager()
//            let isEnabled = biometricManager.isBiometryEnabled(for: account.customer.email)
//            let isPrompt = biometricManager.isBiometryPermissionPrompt(for: account.customer.email)
//            var newUsername = text
//            if let phone = try? self.phoneNumberKit.parse(text) {
//                newUsername = self.phoneNumberKit.format(phone, toType: .national).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//                newUsername = newUsername.hasPrefix("0") ? newUsername.subString(1, length: newUsername.count) : newUsername
//            }
//            biometricManager.setBiometry(isEnabled: isEnabled, phone: newUsername, email: account.customer.email)
//            biometricManager.setBiometryPermission(isPrompt: isPrompt, phone: newUsername, email: account.customer.email)
//        }).disposed(by: disposeBag)
    }
}

private extension ChangePhoneNumberViewModel {
    func formatePhoneNumber(_ phoneNumber: String) -> (phoneNumber: String, formatted: Bool) {
        do {
            let pNumber = try phoneNumberKit.parse(phoneNumber)
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return (formattedNumber, true)
        } catch {
            //            print("error occurred while formatting phone number: \(error)")
        }
        return (phoneNumber, false)
    }

    func attributed(text: String) -> NSAttributedString {
        let length = text.components(separatedBy: " ").first?.count ?? 0
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray.withAlphaComponent(0.5)], range: NSRange(location: 0, length: length == 0 ? text.count : length))
        if length > 0 {
            attributed.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], range: NSRange(location: length, length: text.count - length))
        }
        return attributed
    }

    func format(phonenumber: String) throws -> String {
         if phonenumber.hasPrefix("+") {
             return phonenumber.replacingOccurrences(of: "+", with: "00") } else if phonenumber.hasPrefix("00") {
             return phonenumber
         } else if phonenumber.hasPrefix("0") {
             var phoneno = phonenumber
             phoneno.removeFirst()
             return phoneno
         }
         return phonenumber
     }
}
