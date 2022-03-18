//
//  ASMBTextInputCellViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import UIKit

public protocol ASMBTextInputCellViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var infoTappedObserver: AnyObserver<Void> { get }
    var crossTappedObserver: AnyObserver<Void> { get }
    var becomeResponderObserver: AnyObserver<Bool> { get }
    var resigneObserver: AnyObserver<Void> { get }
    var configObserver: AnyObserver<Void> { get }
    var editingEndObserver: AnyObserver<Void> { get }
    var validObserver: AnyObserver<Bool> { get }
}

public protocol ASMBTextInputCellViewModelOutput {
    var title: Observable<String?> { get }
    var animatesTitleOnEditingBegin: Observable<Bool> { get }
    var text: Observable<String?> { get }
    var placeholder: Observable<String?> { get }
    var valid: Observable<Bool> { get }
    var icon: Observable<UIImage?> { get }
    var infoButtonImage: Observable<UIImage?> { get }
    var crossButtonImage: Observable<UIImage?> { get }
    var attributedText: Observable<NSAttributedString?> { get }
    var isEnabled: Observable<Bool> { get }
    var showsInfoButton: Observable<Bool> { get }
    var showsCrossButton: Observable<Bool> { get }
    var showInfo: Observable<String?> { get }
    var textFieldTextFont: Observable<UIFont> { get }
    var crossButtonTapped: Observable<Void> { get }
    
    var resigned: Observable<Void> { get }
    var becomeResponder: Observable<Bool> { get }
    func canEdit(text: String, replacementText: String, inRange range: NSRange) -> Bool
    var keyboardType: Observable<UIKeyboardType> { get }
    var returnType: Observable<UIReturnKeyType> { get }
    var captalizationType: Observable<UITextAutocapitalizationType> { get }
    var showsAccessory: Observable<Bool> { get }
    var inputError: Observable<String?> { get }
    
}

public protocol ASMBTextInputCellViewModelType {
    var inputs: ASMBTextInputCellViewModelInput { get }
    var outputs: ASMBTextInputCellViewModelOutput { get }
}

public class ASMBTextInputCellViewModel: ASMBTextInputCellViewModelType, ASMBTextInputCellViewModelInput, ASMBTextInputCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: ASMBTextInputCellViewModelInput { return self }
    public var outputs: ASMBTextInputCellViewModelOutput { return self }
    public var reusableIdentifier: String { ASMBTextInputCell.defaultIdentifier }
    
    private let textObserverSubject = PublishSubject<String?>()
    let textFieldTextFontSubject = BehaviorSubject<UIFont>(value: .large)
    let textSubject = BehaviorSubject<String?>(value: nil)
    let animatedTitleSubject = BehaviorSubject<Bool>(value: false)
    let placeholderSubject = BehaviorSubject<String?>(value: nil)
    let titleSubject = BehaviorSubject<String?>(value: nil)
    let validSubject = BehaviorSubject<Bool>(value: false)
    let iconSubject = BehaviorSubject<UIImage?>(value:nil)
    let attributedTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    let isEnabledSubject = BehaviorSubject<Bool>(value: true)
    let infoTappedObserverSubject = PublishSubject<Void>()
    let crossTappedObserverSubject = PublishSubject<Void>()
    let showsInfoButtonSubject = BehaviorSubject<Bool>(value: false)
    let showsCrossButtonSubject = BehaviorSubject<Bool>(value: false)
    let infoButtonImageSubject = BehaviorSubject<UIImage?>(value: nil)
    let crossButtonImageSubject = BehaviorSubject<UIImage?>(value: nil)
    let showInfoSubject = PublishSubject<String?>()
    let configSubject = PublishSubject<Void>()
    let editingEndSubject = PublishSubject<Void>()
    
    let resignedSubject = PublishSubject<Void>()
    let becomeResponderSubject = PublishSubject<Bool>()
    let keyboardTypeSubject = BehaviorSubject<UIKeyboardType>(value: .default)
    let returnTypeSubject = BehaviorSubject<UIReturnKeyType>(value: .next)
    let captalizationTypeSubject = BehaviorSubject<UITextAutocapitalizationType>(value: .sentences)
    let showsAccessorySubject = BehaviorSubject<Bool>(value: false)
    
    let inputType: InputType!
    let beneficiary: SendMoneyBeneficiary?
    private let inputErrorSubject = PublishSubject<String?>()
    
    // MARK: - Inputs
    public var textObserver: AnyObserver<String?> { return textObserverSubject.asObserver() }
    public var infoTappedObserver: AnyObserver<Void> { return infoTappedObserverSubject.asObserver() }
    public var crossTappedObserver: AnyObserver<Void> { crossTappedObserverSubject.asObserver() }
    public var becomeResponderObserver: AnyObserver<Bool> { return becomeResponderSubject.asObserver() }
    public var resigneObserver: AnyObserver<Void> { return resignedSubject.asObserver() }
    public var configObserver: AnyObserver<Void> { configSubject.asObserver() }
    public var editingEndObserver: AnyObserver<Void> { editingEndSubject.asObserver() }
    public var validObserver: AnyObserver<Bool> { validSubject.asObserver() }
    
    // MARK: - Outputs
    public var text: Observable<String?> { return textSubject.map{ $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.asObservable() }
    public var animatesTitleOnEditingBegin: Observable<Bool> { return animatedTitleSubject.asObservable() }
    public var title: Observable<String?> { return titleSubject.asObservable() }
    public var valid: Observable<Bool> { return validSubject.asObservable() }
    public var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    public var infoButtonImage: Observable<UIImage?> { return infoButtonImageSubject.asObservable() }
    public var crossButtonImage: Observable<UIImage?> { crossButtonImageSubject.asObservable() }
    public var placeholder: Observable<String?> { return placeholderSubject.asObservable() }
    public var attributedText: Observable<NSAttributedString?> { return attributedTextSubject.asObservable() }
    public var isEnabled: Observable<Bool> { return isEnabledSubject.asObservable() }
    public var showsInfoButton: Observable<Bool> { return showsInfoButtonSubject.asObservable() }
    public var showsCrossButton: Observable<Bool> { showsCrossButtonSubject.asObservable() }
    public var showInfo: Observable<String?> { return showInfoSubject.asObservable() }
    public var textFieldTextFont: Observable<UIFont> { textFieldTextFontSubject.asObservable() }
    public var resigned: Observable<Void> { return resignedSubject.asObservable() }
    public var becomeResponder: Observable<Bool> { return becomeResponderSubject.asObservable() }
    public var keyboardType: Observable<UIKeyboardType> { return keyboardTypeSubject.asObservable() }
    public var returnType: Observable<UIReturnKeyType> { return returnTypeSubject.asObservable() }
    public var captalizationType: Observable<UITextAutocapitalizationType> { return captalizationTypeSubject.asObservable() }
    public var showsAccessory: Observable<Bool> { return showsAccessorySubject.asObservable() }
    public var inputError: Observable<String?> { inputErrorSubject.asObservable() }
    public var crossButtonTapped: Observable<Void> { crossTappedObserverSubject.asObservable() }
    
    // MARK: - Init
    public init(_ inputType: ASMBTextInputCellViewModel.InputType, beneficiary: SendMoneyBeneficiary? = nil, title: String? = nil, placeholder: String? = nil, isReviewing: Bool = false, isEnabled: Bool = true) {
        self.inputType = inputType
        self.beneficiary = beneficiary
        
        showsInfoButtonSubject.onNext(inputType.info != nil && !isReviewing)
        infoTappedObserverSubject.map { inputType.info }.bind(to: showInfoSubject).disposed(by: disposeBag)
        
        configSubject.withLatestFrom(textSubject).map{ $0 == nil ? nil : NSAttributedString(string: $0!) }.bind(to: attributedTextSubject).disposed(by: disposeBag)
        
        textObserverSubject
            .map { text -> Bool in
                guard let allowed = inputType.allowedCharacters else { return true }
                return text?.trimmingCharacters(in: CharacterSet.init(charactersIn: allowed)).isEmpty ?? true }
            .map{ $0 ? nil : inputType.invalidCharacterError }
            .bind(to: inputErrorSubject).disposed(by: disposeBag)
        
        textObserverSubject
            .map{ text -> String? in
                var text = text
                if let allowed = inputType.allowedCharacters {
                    text?.removeAll{ !allowed.contains($0) }
                }
                return text  }
            .bind(to: textSubject)
            .disposed(by: disposeBag)
        
        textObserverSubject.subscribe(onNext: { [unowned self] text in
            showsCrossButtonSubject.onNext(inputType == .nickname && !(text?.isEmpty ?? true))
        }).disposed(by: disposeBag)
    }
    
    public func canEdit(text: String, replacementText: String, inRange range: NSRange) -> Bool {
        return true
    }
}

public extension ASMBTextInputCellViewModel {
    enum InputType {
        case nickname
        case transferType
        case firstName
        case lastName
        case phoneNumber
        case phoneNumberOptional
        case iban
        case confirmIban
        case country
        case accountOrIban
        case swift
        case bankName
        case branchName
        case bankCity
        case custome
    }
}

extension ASMBTextInputCellViewModel.InputType {
    var title: String {
        switch self {
        case .transferType:
            return "screen_send_money_edit_beneficiary_display_text_transfer_type".localized
        case .nickname:
            return "screen_add_beneficiary_detail_display_text_transfer_nick_name".localized
        case .firstName:
            return "screen_add_beneficiary_detail_display_text_transfer_first_name".localized
        case .lastName:
            return "screen_add_beneficiary_detail_display_text_transfer_last_name".localized
        case .phoneNumber:
            return "screen_add_beneficiary_detail_display_text_transfer_phone".localized
        case .phoneNumberOptional:
            return "screen_add_beneficiary_detail_display_text_transfer_phone_optional".localized
        case .iban:
            return "screen_beneficiary_account_details_display_text_iban".localized
        case .confirmIban:
            return "screen_sdd_beneficiary_display_confirm_iban".localized
        case .country:
            return "screen_add_beneficiary_detail_display_text_country".localized
        case .accountOrIban:
            return "screen_beneficiary_overview_display_text_account_number_iban".localized
        case .swift:
            return "screen_beneficiary_overview_display_text_swift_code".localized
        case .bankName:
            return "screen_bank_details_display_text_bank_name".localized
        case .branchName:
            return "screen_bank_details_input_text_branch_hint".localized
        case .bankCity:
            return "screen_bank_details_display_text_bank_city".localized
        case .custome:
            return ""
        }
    }
    
    var placeholder: String {
        switch self {
        case .transferType:
            return "screen_send_money_edit_beneficiary_display_text_transfer_type".localized
        case .nickname:
            return "screen_add_beneficiary_detail_input_text_nick_name_hint".localized
        case .firstName:
            return "screen_add_beneficiary_detail_input_text_first_name_hint".localized
        case .lastName:
            return "screen_add_beneficiary_detail_input_text_last_name_hint".localized
        case .phoneNumber, .phoneNumberOptional:
            return ""
        case .iban, .confirmIban:
            return "xxxxxxxxxx"
        case .country:
            return ""
        case .accountOrIban:
            return "screen_add_beneficiary_detail_display_text_iban".localized
        case .swift:
            return "screen_bank_details_display_text_swift_code".localized
        case .bankName:
            return "screen_bank_details_display_text_bank_name".localized
        case .branchName:
            return "screen_bank_details_input_text_branch_hint".localized
        case .bankCity:
            return "screen_bank_details_display_text_bank_city".localized
        case .custome:
            return ""
        }
    }
    
    var reviewTitle: String {
        switch self {
        case .transferType:
            return "screen_send_money_edit_beneficiary_display_text_transfer_type".localized
        case .nickname:
            return "screen_add_beneficiary_detail_display_text_transfer_nick_name".localized
        case .firstName:
            return "screen_add_beneficiary_detail_display_text_transfer_first_name".localized
        case .lastName:
            return "screen_add_beneficiary_detail_display_text_transfer_last_name".localized
        case .phoneNumber:
            return "screen_add_beneficiary_detail_display_text_transfer_phone".localized
        case .phoneNumberOptional:
            return "screen_add_beneficiary_detail_display_text_transfer_phone_optional".localized
        case .iban:
            return "IBAN"
        case .confirmIban:
            return ""
        case .country:
            return ""
        case .accountOrIban:
            return "screen_beneficiary_overview_display_text_account_number_iban".localized
        case .swift:
            return "screen_beneficiary_overview_display_text_swift_code".localized
        case .bankName:
            return "screen_bank_details_display_text_bank_name".localized
        case .branchName:
            return "screen_bank_details_input_text_branch_hint".localized
        case .bankCity:
            return "screen_bank_details_display_text_bank_city".localized
        case .custome:
            return ""
        }
    }
    
    var info: String? {
        switch self {
        case .iban, .swift:
            return "Your IBAN is a sequence of 23 characters and can be found in the top right menu on your dashboard"
        default:
            return nil
        }
    }
    
    var allowedCharacters: String? {
        switch self {
        case .firstName, .lastName, .bankName, .bankCity, .branchName, .nickname, .country, .transferType:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefgjhiklmnopqrstuvwxyz "
        case .confirmIban, .swift, .iban:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        case .accountOrIban:
            return "0123456789"
        case .custome, .phoneNumber, .phoneNumberOptional:
            return nil
        }
    }
    
    var invalidCharacterError: String? {
        switch self {
        case .firstName, .lastName, .bankName, .bankCity, .branchName, .nickname, .country:
            return "Only english alphabets are allowed"
        case .confirmIban, .swift, .iban:
            return "Only alpha numeric characters are allowed"
        case .accountOrIban:
            return "Only numberic characters are allowed"
        case .custome, .phoneNumber, .phoneNumberOptional, .transferType:
            return nil
        }
    }
}
