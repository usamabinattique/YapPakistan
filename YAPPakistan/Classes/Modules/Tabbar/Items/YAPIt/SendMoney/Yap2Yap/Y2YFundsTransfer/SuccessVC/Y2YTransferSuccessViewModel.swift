//
//  Y2YTransferSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 27/01/2022.
//

import Foundation
import RxSwift
import YAPComponents
import UIKit

protocol Y2YTransferSuccessViewModelInput {
    var confirmObsever: AnyObserver<Void> { get }
}

protocol Y2YTransferSuccessViewModelOutput {
    var confirm: Observable<Void> { get }
    
    var userImage: Observable<(String?, UIImage?)> { get }
    var userName: Observable<String?> { get }
    var amount: Observable<String?> { get }
    var phone: Observable<String> { get }
    var reference: Observable<String> { get }
    var date: Observable<String> { get }
}

protocol Y2YTransferSuccessViewModelType {
    var inputs: Y2YTransferSuccessViewModelInput { get }
    var outputs: Y2YTransferSuccessViewModelOutput { get }
}

class Y2YTransferSuccessViewModel: Y2YTransferSuccessViewModelType, Y2YTransferSuccessViewModelInput, Y2YTransferSuccessViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: Y2YTransferSuccessViewModelInput { return self }
    var outputs: Y2YTransferSuccessViewModelOutput { return self }
    
    private let confirmSubject = PublishSubject<Void>()
    
    private let userImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let userNameSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = BehaviorSubject<String?>(value: nil)
    
    private let phoneSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let refernceSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let dateSubject = ReplaySubject<String>.create(bufferSize: 1)
    
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
    
    // MARK: - Init
    init(_ contact: YAPContact, _ amount: Double) {
        
        //TODO: {YASIR} utilize this contact.name.initialsImage color in your VC
        userImageSubject.onNext((contact.photoUrl, contact.thumbnailImage ?? contact.name.initialsImage(color: UIColor.green.withAlphaComponent(0.5))))
        userNameSubject.onNext(contact.name)
        amountSubject.onNext(CurrencyFormatter.formatAmountInLocalCurrency(amount))
        
        phoneSubject.onNext("Mobile number: \(contact.phoneNumber)")
       
        //TODO: add refence number and date
        refernceSubject.onNext("Refernce number: ")
        dateSubject.onNext("Jan 29, 2021・10:35 AM")
    }
}