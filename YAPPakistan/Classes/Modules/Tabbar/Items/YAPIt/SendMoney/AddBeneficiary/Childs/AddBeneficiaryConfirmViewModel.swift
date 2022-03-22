//
//  AddBeneficiaryConfirmViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 17/03/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxCocoa
import RxDataSources
import RxTheme
import UIKit

protocol AddBeneficiaryConfirmViewModelInput {
    var doneObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
//    var otpResultObserver: AnyObserver<ResultType<String?>> { get }
    var cancelObserver: AnyObserver<Void>{ get }
    
    var resigneObserver: AnyObserver<Void> { get }
    var configObserver: AnyObserver<Void> { get }
    var editingEndObserver: AnyObserver<Void> { get }
    
    //Account number/IBAN
    var textObserver: AnyObserver<String?> { get }
}

protocol AddBeneficiaryConfirmViewModelOutput {
    
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    
    var showsDone: Observable<Bool> { get }
    var doneText: Observable<String?> { get }
    var doneEnabled: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var showActivity: Observable<Bool> { get }
    var endEditing: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var result: Observable<SendMoneyBeneficiary> { get }
    var beneficairyAdded: Observable<SendMoneyBeneficiary?> { get }
    var navTitle: Observable<String?> { get }
    var otpRequired: Observable<SendMoneyBeneficiary> { get }
    var cancel: Observable<Void>{ get }
    var search: Observable<[BankDetail]?> { get }
    
    var name: Observable<String?> { get }
    var bankImage: Observable<(String?, UIImage?)> { get }
    var accountNumber: Observable<String> { get }
    
    //Account number/IBAN
    var title: Observable<String?> { get }
    var animatesTitleOnEditingBegin: Observable<Bool> { get }
    var text: Observable<String?> { get }
    var placeholder: Observable<String?> { get }
    var valid: Observable<Bool> { get }
    var icon: Observable<UIImage?> { get }
    var attributedText: Observable<NSAttributedString?> { get }
    var isEnabled: Observable<Bool> { get }
    var showsInfoButton: Observable<Bool> { get }
    var showInfo: Observable<String?> { get }
    
    var resigned: Observable<Void> { get }
    var becomeResponder: Observable<Bool> { get }
    func canEdit(text: String, replacementText: String, inRange range: NSRange) -> Bool
    var keyboardType: Observable<UIKeyboardType> { get }
    var returnType: Observable<UIReturnKeyType> { get }
    var captalizationType: Observable<UITextAutocapitalizationType> { get }
    var showsAccessory: Observable<Bool> { get }
    var inputError: Observable<Bool> { get }
    var userImage: Observable<(String?,UIImage?)> { get }
    var accountTitle: Observable<String> { get }
    var otpResult: Observable<ResultType<AddBankBeneficiaryRequest>> { get }
}

protocol AddBeneficiaryConfirmViewModelType {
    var inputs: AddBeneficiaryConfirmViewModelInput { get }
    var outputs: AddBeneficiaryConfirmViewModelOutput { get }
}

class AddBeneficiaryConfirmViewModel: AddBeneficiaryConfirmViewModelType, AddBeneficiaryConfirmViewModelInput, AddBeneficiaryConfirmViewModelOutput {
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddBeneficiaryConfirmViewModelInput { return self }
    var outputs: AddBeneficiaryConfirmViewModelOutput { return self }
    
    var repository : OTPRepositoryType!
    
    let beneficiaryAddedSubject = PublishSubject<SendMoneyBeneficiary?>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let bankImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    
    let doneSubject = PublishSubject<Void>()
    let showsDoneSubject = BehaviorSubject<Bool>(value: true)
    let doneTextSubject = BehaviorSubject<String?>(value: nil)
    let doneEnabledSubject = BehaviorSubject<Bool>(value: false)
    let showActivitySubject = BehaviorSubject<Bool>(value: false)
    let endEditingSubject = BehaviorSubject<Bool>(value: false)
    let showErrorSubject = PublishSubject<String>()
    let resultSubject = PublishSubject<SendMoneyBeneficiary>()
    private let backSubject = PublishSubject<Void>()
    let cellSelectedSubject = PublishSubject<ReusableTableViewCellViewModelType>()
    let navTitleSubject = BehaviorSubject<String?>(value: "screen_add_beneficiary_display_text_title".localized)
    let otpRequiredSubject = PublishSubject<SendMoneyBeneficiary>()
    let otpResultSubject = PublishSubject<ResultType<AddBankBeneficiaryRequest>>()
    let cancelSubject = PublishSubject<Void>()
    
    private let searchSubject = PublishSubject<Void>()
    var beneficiary: SendMoneyBeneficiary!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    let sendMoneyType: SendMoneyType
    
    private let bankResultsSubject = BehaviorSubject<[BankDetail]?>(value: nil)
    
    
    //Account number/IBAN
    private let textObserverSubject = PublishSubject<String?>()
    let textSubject = BehaviorSubject<String?>(value: nil)
    let animatedTitleSubject = BehaviorSubject<Bool>(value: false)
    let placeholderSubject = BehaviorSubject<String?>(value: nil)
    let titleSubject = BehaviorSubject<String?>(value: nil)
    let validSubject = BehaviorSubject<Bool>(value: false)
    let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    let attributedTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    let isEnabledSubject = BehaviorSubject<Bool>(value: true)
    let infoTappedObserverSubject = PublishSubject<Void>()
    let showsInfoButtonSubject = BehaviorSubject<Bool>(value: false)
    let showInfoSubject = PublishSubject<String?>()
    let configSubject = PublishSubject<Void>()
    let editingEndSubject = PublishSubject<Void>()
    
    let resignedSubject = PublishSubject<Void>()
    let becomeResponderSubject = PublishSubject<Bool>()
    let keyboardTypeSubject = BehaviorSubject<UIKeyboardType>(value: .default)
    let returnTypeSubject = BehaviorSubject<UIReturnKeyType>(value: .next)
    let captalizationTypeSubject = BehaviorSubject<UITextAutocapitalizationType>(value: .sentences)
    let showsAccessorySubject = BehaviorSubject<Bool>(value: false)
    let accountNumberSubject = ReplaySubject<String>.create(bufferSize: 1)
    let userImageSubject = ReplaySubject<UIImage?>.create(bufferSize: 1)
    let accountTitleSubject = ReplaySubject<String>.create(bufferSize: 1)
    
   
    private let inputErrorSubject = PublishSubject<Bool>()
    
    // MARK: - Inputs
    var searchObserver: AnyObserver<Void> { return searchSubject.asObserver() }
    var cancelObserver: AnyObserver<Void>{ return cancelSubject.asObserver() }
    var doneObserver: AnyObserver<Void> { return doneSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var cellSelected: AnyObserver<ReusableTableViewCellViewModelType> { return cellSelectedSubject.asObserver() }
    var otpResultObserver: AnyObserver<ResultType<AddBankBeneficiaryRequest>> { otpResultSubject.asObserver() }
    
    //Account number/IBAN
    public var textObserver: AnyObserver<String?> { return textObserverSubject.asObserver() }
    public var infoTappedObserver: AnyObserver<Void> { return infoTappedObserverSubject.asObserver() }
    public var becomeResponderObserver: AnyObserver<Bool> { return becomeResponderSubject.asObserver() }
    public var resigneObserver: AnyObserver<Void> { return resignedSubject.asObserver() }
    public var configObserver: AnyObserver<Void> { configSubject.asObserver() }
    public var editingEndObserver: AnyObserver<Void> { editingEndSubject.asObserver() }
    public var validObserver: AnyObserver<Bool> { validSubject.asObserver() }
    
    // MARK: - Outputs
    var navTitle: Observable<String?> { return navTitleSubject.asObservable() }
    var cancel: Observable<Void>{ return cancelSubject.asObservable() }
    var showsDone: Observable<Bool> { return showsDoneSubject.asObservable() }
    var doneText: Observable<String?> { return doneTextSubject.asObservable() }
    var doneEnabled: Observable<Bool> { return doneEnabledSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var endEditing: Observable<Bool> { return endEditingSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var result: Observable<SendMoneyBeneficiary> { return resultSubject.asObservable() }
    var beneficairyAdded: Observable<SendMoneyBeneficiary?> { return beneficiaryAddedSubject.asObservable() }
    var otpRequired: Observable<SendMoneyBeneficiary> { otpRequiredSubject.asObservable() }
    var search: Observable<[BankDetail]?> { return searchSubject.withLatestFrom(bankResultsSubject) }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var bankImage: Observable<(String?, UIImage?)> { return bankImageSubject.asObservable() }
    
    //Account number/IBAN
    public var text: Observable<String?> { return textSubject.map{ $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.asObservable() }
    public var animatesTitleOnEditingBegin: Observable<Bool> { return animatedTitleSubject.asObservable() }
    public var title: Observable<String?> { return titleSubject.asObservable() }
    public var valid: Observable<Bool> { return validSubject.asObservable() }
    public var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    public var placeholder: Observable<String?> { return placeholderSubject.asObservable() }
    public var attributedText: Observable<NSAttributedString?> { return attributedTextSubject.asObservable() }
    public var isEnabled: Observable<Bool> { return isEnabledSubject.asObservable() }
    public var showsInfoButton: Observable<Bool> { return showsInfoButtonSubject.asObservable() }
    public var showInfo: Observable<String?> { return showInfoSubject.asObservable() }
    public var resigned: Observable<Void> { return resignedSubject.asObservable() }
    public var becomeResponder: Observable<Bool> { return becomeResponderSubject.asObservable() }
    public var keyboardType: Observable<UIKeyboardType> { return keyboardTypeSubject.asObservable() }
    public var returnType: Observable<UIReturnKeyType> { return returnTypeSubject.asObservable() }
    public var captalizationType: Observable<UITextAutocapitalizationType> { return captalizationTypeSubject.asObservable() }
    public var showsAccessory: Observable<Bool> { return showsAccessorySubject.asObservable() }
    public var inputError: Observable<Bool> { inputErrorSubject.asObservable() }
    var userImage: Observable<(String?,UIImage?)> { userImageSubject.map({ img -> (String?, UIImage?) in
        return (nil,img)
    }).asObservable() }
    var accountTitle: Observable<String> { accountTitleSubject.asObservable() }
    
    var accountNumber: Observable<String> { accountNumberSubject.asObservable() }
    var otpResult: Observable<ResultType<AddBankBeneficiaryRequest>> { otpResultSubject.asObservable() }
    
    private var searchableActionSheet: SearchableActionSheet?
    private var themeService: ThemeService<AppTheme>
    private var bank: BankDetail
    
    // MARK: - Init
    init(beneficiary: SendMoneyBeneficiary,
         repository: OTPRepositoryType,
         sendMoneyType: SendMoneyType, themeService: ThemeService<AppTheme>, bank: BankDetail, accountDetail: BankAccountDetail) {
        
        self.sendMoneyType = sendMoneyType
        self.repository = repository
        self.beneficiary = beneficiary
        self.themeService = themeService
        self.bank = bank
        
        nameSubject.onNext(bank.bankName)
        bankImageSubject.onNext((bank.bankLogoUrl, bank.bankName.thumbnail))
        accountNumberSubject.onNext(accountDetail.accountNo)
        userImageSubject.onNext(accountDetail.title.thumbnail)
        accountTitleSubject.onNext(accountDetail.title)
        
        showsInfoButtonSubject.onNext(true)
        infoTappedObserverSubject.map { bank.formatMessage }.bind(to: showInfoSubject).disposed(by: disposeBag)
        
        configSubject.withLatestFrom(textSubject).map{ $0 == nil ? nil : NSAttributedString(string: $0!) }.bind(to: attributedTextSubject).disposed(by: disposeBag)
        
        textObserverSubject.unwrap()
            .map { text -> Bool in
                text.count >= bank.accountNoMinLength && text.count <= bank.ibanMaxLength
            }
            //.map{ "\($0)" }
            .bind(to: inputErrorSubject).disposed(by: disposeBag)
        
        
        textObserverSubject.bind(to: textSubject).disposed(by: disposeBag)
        
        doneSubject.withLatestFrom(textObserverSubject).unwrap().subscribe(onNext: { [weak self] nickName in
            let theName = nickName.count > 0 ? nickName : nil
            let input = AddBankBeneficiaryRequest(title: accountDetail.title, accountNo: accountDetail.accountNo, bankName: bank.bankName, nickName: theName, beneficiaryType: "IBFT")
            self?.generateOtp(input: input)
        }).disposed(by: disposeBag)

    }
    
    func generateCellViewModels() {
        fatalError("'generateCellViewModels()' not implementd")
    }
    
    internal func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
        showActivitySubject.onNext(false)
    }
    
    func fetchRequiredData() {}
    
    public func canEdit(text: String, replacementText: String, inRange range: NSRange) -> Bool {
        return true
    }
}

// MARK: Beneficiary Added

extension AddBeneficiaryConfirmViewModel {
    func showBeneficiaryAddedAlert() {
        let title = "screen_add_beneficiary_detail_display_text_alert_title".localized
        let details = "screen_add_beneficiary_detail_display_button_block_alert_description".localized
        let text = title + "\n\n\n" + details + "\n"
        
        let attributted = NSMutableAttributedString(string: text)
        
        attributted.addAttributes([.foregroundColor: UIColor(themeService.attrs.primaryDark), .font: UIFont.title3], range: NSRange(location: 0, length: title.count))
        attributted.addAttributes([.foregroundColor: UIColor(themeService.attrs.greyDark), .font: UIFont.small], range: NSRange(location: text.count - details.count - 1, length: details.count))
        
        let alert = YAPAlertView(theme: themeService, icon: UIImage.init(named: "icon_check_fill_purple", in: .yapPakistan), text: attributted, primaryButtonTitle: "screen_add_beneficiary_detail_display_button_block_alert_yes".localized, cancelButtonTitle: "screen_add_beneficiary_detail_display_button_block_alert_no".localized)
        
        alert.show()
        
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        attributted.addAttributes([.paragraphStyle: para], range: NSRange(location: 0, length: text.count))
        
        Observable.merge(alert.rx.primaryTap.map { [unowned self]  in self.beneficiary }, alert.rx.cancelTap.map({ ele -> SendMoneyBeneficiary? in
            return nil
        })).bind(to: beneficiaryAddedSubject).disposed(by: disposeBag)
    }
    
    func generateOtp(input: AddBankBeneficiaryRequest) {
        self.otpResultSubject.onNext(.success((input)))
    }
}
