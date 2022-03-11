//
//  QRPaymentSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 10/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import UIKit

protocol QRPaymentSuccessViewModelInput {
    var confirmObsever: AnyObserver<Void> { get }
}

protocol QRPaymentSuccessViewModelOutput {
    var confirm: Observable<Void> { get }
    
    var userImage: Observable<(String?, UIImage?)> { get }
    var userName: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var phone: Observable<String> { get }
    var reference: Observable<String> { get }
    var date: Observable<String> { get }
    var firstName: Observable<String?> { get }
    var userPhoneNumber: Observable<String?> { get }
}

protocol QRPaymentSuccessViewModelType {
    var inputs: QRPaymentSuccessViewModelInput { get }
    var outputs: QRPaymentSuccessViewModelOutput { get }
}

class QRPaymentSuccessViewModel: QRPaymentSuccessViewModelType, QRPaymentSuccessViewModelInput, QRPaymentSuccessViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: QRPaymentSuccessViewModelInput { return self }
    var outputs: QRPaymentSuccessViewModelOutput { return self }
    
    private let confirmSubject = PublishSubject<Void>()
    
    private let userImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let userNameSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    
    private let phoneSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let refernceSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let dateSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let firstNameSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let userPhoneSubject = ReplaySubject<String?>.create(bufferSize: 1)
    
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
    
    // MARK: - Init
    init(_ contact: YAPContact, _ transaction: Y2YTransactionResponse) {
        userImageSubject.onNext((contact.photoUrl, contact.name.initialsImage(color: UIColor(Color(hex: "#F44774")))))
        userNameSubject.onNext(contact.name)
        amountSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(Double(transaction.amountTransferred) ?? 0))
        
        phoneSubject.onNext("Mobile number: \(contact.formattedPhoneNumber)")
        userPhoneSubject.onNext(contact.formattedPhoneNumberForQRCode)
        
        let firstName = "screen_y2y_funds_transfer_success_display_text_transfer".localized + " " +  (contact.name.components(separatedBy: " ").first ?? "")
        firstNameSubject.onNext(firstName)
       
        refernceSubject.onNext("Refernce number: \(transaction.transactionId)")
        
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, yyyy . h:mm a"
        
        if let date = transaction.date.date(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS") {
            let stringDate = dateFormatterPrint.string(from: date)
            dateSubject.onNext("\(stringDate)")
        }
        
    }
}
