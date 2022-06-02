//
//  SendMoneyFundsTransferViaBankSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import UIKit

protocol SendMoneyFundsTransferViaBankSuccessViewModelInput {
    var confirmObsever: AnyObserver<Void> { get }
}

protocol SendMoneyFundsTransferViaBankSuccessViewModelOutput {
    var confirm: Observable<Void> { get }
    
    var userImage: Observable<(String?, UIImage?)> { get }
    var userName: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var phone: Observable<String> { get }
    var reference: Observable<String> { get }
    var date: Observable<String> { get }
    var firstName: Observable<String?> { get }
    var userPhoneNumber: Observable<String?> { get }
    var bankImage: Observable<(String?, UIImage?)> { get }
    var bankName: Observable<String?> { get }
}

protocol SendMoneyFundsTransferViaBankSuccessViewModelType {
    var inputs: SendMoneyFundsTransferViaBankSuccessViewModelInput { get }
    var outputs: SendMoneyFundsTransferViaBankSuccessViewModelOutput { get }
}

class SendMoneyFundsTransferViaBankSuccessViewModel: SendMoneyFundsTransferViaBankSuccessViewModelType, SendMoneyFundsTransferViaBankSuccessViewModelInput, SendMoneyFundsTransferViaBankSuccessViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SendMoneyFundsTransferViaBankSuccessViewModelInput { return self }
    var outputs: SendMoneyFundsTransferViaBankSuccessViewModelOutput { return self }
    
    private let confirmSubject = PublishSubject<Void>()
    
    private let userImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let userNameSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    
    private let phoneSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let refernceSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let dateSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let firstNameSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let userPhoneSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let bankNameSubject = BehaviorSubject<String?>(value: nil)
    private let bankImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    
    // MARK: - Inputs
    var confirmObsever: AnyObserver<Void> { return confirmSubject.asObserver() }
    
    // MARK: - Outputs
    var confirm: Observable<Void> { return confirmSubject.asObservable() }
    var userImage: Observable<(String?, UIImage?)> { return userImageSubject.asObservable() }
    var userName: Observable<String?> { return userNameSubject.asObservable() }
    var amount: Observable<String?> { return amountSubject.asObservable() }
    var phone: Observable<String> { return phoneSubject.asObservable() }
    var reference: Observable<String> { return refernceSubject.asObservable() }
    var date: Observable<String> { return dateSubject.asObservable() }
    var firstName: Observable<String?> { return  firstNameSubject.asObservable() }
    var userPhoneNumber: Observable<String?> { return userPhoneSubject.asObservable() }
    var bankName: Observable<String?> {  bankNameSubject.asObservable() }
    var bankImage: Observable<(String?, UIImage?)> { return bankImageSubject.asObservable() }
    
    // MARK: - Init
    init(_ beneficiary: SendMoneyBeneficiary, _ transaction: BankTransferResponse) {
        let name = beneficiary.title ?? ""
        userImageSubject.onNext((beneficiary.beneficiaryPictureUrl, name.thumbnail))
        userNameSubject.onNext(name)
        amountSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(Double(transaction.amountTransferred) ?? 0))
        
        phoneSubject.onNext("Account number: \(transaction.accountNo)")
        
        
        let firstName = "screen_y2y_funds_transfer_success_display_text_transfer".localized
        firstNameSubject.onNext(firstName)
       
        refernceSubject.onNext("Refernce number: \(transaction.transactionId)")
        
        bankNameSubject.onNext(transaction.bankName)
        bankImageSubject.onNext((transaction.bankLogoURL, transaction.bankName.thumbnail))
        
//        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "MMM d, yyyy . h:mm a"
//
//        if let date = transaction.date.date(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS") {
//            let stringDate = dateFormatterPrint.string(from: date)
//            dateSubject.onNext("\(stringDate)")
//        }
        //TODO: [UMAIR] - this is temporarily added format, remove once format corrected by server
        guard let isoDate = Date(iso8601String: "\(transaction.date)Z") else {
            dateSubject.onNext(Date().dateTimeString())
            return
        }
        dateSubject.onNext(isoDate.dateTimeString())
        
    }
}
