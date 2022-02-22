//
//  ConfirmPaymentViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 16/02/2022.
//

import Foundation
import RxSwift
import UIKit
import YAPComponents

protocol ConfirmPaymentViewModelInputs {
    var closeObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var editObserver: AnyObserver<Void> { get }
}

protocol ConfirmPaymentViewModelOutputs {
    var close: Observable<Void> { get }
    var next: Observable<Int> { get }
    var isEnabled: Observable<Bool> { get }
    var completedSteps: Observable<Int> { get }
    var localizedStrings: Observable<ConfirmPaymentViewModel.LocalizedStrings> { get }
    var edit: Observable<Void> { get }
    var cardImage: Observable<UIImage?> { get }
    var isPaid: Observable<Bool> { get }
    var cardFee: Observable<String> { get }
    var cardNumber: Observable<String> { get }
    var address: Observable<LocationModel> { get }
    var buttonTitle: Observable<String> { get }
}

protocol ConfirmPaymentViewModelType {
    var inputs: ConfirmPaymentViewModelInputs { get }
    var outputs: ConfirmPaymentViewModelOutputs { get }
}

class ConfirmPaymentViewModel: ConfirmPaymentViewModelType, ConfirmPaymentViewModelInputs, ConfirmPaymentViewModelOutputs {
    
    
    var inputs: ConfirmPaymentViewModelInputs { return self }
    var outputs: ConfirmPaymentViewModelOutputs { return self }
    
    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { backSubject.asObserver() }
    var editObserver: AnyObserver<Void> { editSubject.asObserver() }
    
    // MARK: Outputs
    var close: Observable<Void> { backSubject.asObservable() }
    var next: Observable<Int> { nextResultSubject.asObservable() }
    var isEnabled: Observable<Bool> { isEnabledSubject.asObservable() }
    var completedSteps: Observable<Int> { completedStepsSubject.asObservable() }
    var localizedStrings: Observable<LocalizedStrings> { localizedStringsSubject.asObservable() }
    var edit: Observable<Void> { editSubject.asObservable() }
    var cardImage: Observable<UIImage?> { cardImageSubject.asObservable() }
    var isPaid: Observable<Bool> { isPaidSubject.asObservable() }
    var cardFee: Observable<String> { feeSubject.asObservable() }
    var cardNumber: Observable<String> { cardNumberSubject.asObservable() }
    var address: Observable<LocationModel> { addressSubject.asObservable() }
    var buttonTitle: Observable<String> { buttonTitleSubject.asObservable() }
    
    // MARK: Subjects
    private let backSubject = PublishSubject<Void>()
    private let nextSubject = PublishSubject<Void>()
    private let nextResultSubject = PublishSubject<Int>()
    private let isEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let completedStepsSubject = BehaviorSubject<Int>(value: 0)
    private let localizedStringsSubject = BehaviorSubject(value: LocalizedStrings())
    private let editSubject = PublishSubject<Void>()
    private let cardImageSubject = ReplaySubject<UIImage?>.create(bufferSize: 1)
    private let isPaidSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let feeSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let cardNumberSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let addressSubject = ReplaySubject<LocationModel>.create(bufferSize: 1)
    private let buttonTitleSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let paymentGatewayM: PaymentGatewayLocalModel!
    private let kycRepository: KYCRepository
    private let transactionRepository: TransactionsRepository
    private var confirmPaymentCreated = 0
    private var accountProvider: AccountProvider!
    
    init(accountProvider: AccountProvider, kycRepository: KYCRepository, transactionRepository: TransactionsRepository, paymentGatewayObj: PaymentGatewayLocalModel? = nil){
        
        self.paymentGatewayM = paymentGatewayObj
        self.accountProvider = accountProvider
        
        self.kycRepository = kycRepository
        self.transactionRepository = transactionRepository
        
        
        var theStrings = LocalizedStrings(title: "screen_yap_confirm_payment_display_text_toolbar_title".localized, subTitle: "screen_yap_confirm_payment_display_text_toolbar_subtitle".localized,cardFee: "screen_yap_confirm_payment_display_text_Card_fee".localized, payWith: "screen_yap_confirm_payment_display_text_pay_with".localized, action: "Place order for PKR 1,000")
        //    localizedStringsSubject.onNext(strings)
        if let payment = paymentGatewayM {
            let cardImageName = payment.cardSchemeObject?.scheme == .Mastercard ? "payment_card" : "image_payment_card_white_paypak"
            cardImageSubject.onNext(UIImage(named: cardImageName, in: .yapPakistan))
            theStrings.subTitle = payment.cardSchemeObject?.scheme == .Mastercard ? "screen_kyc_card_scheme_title_mastercard".localized : "screen_yap_confirm_payment_display_text_toolbar_subtitle".localized
            isPaidSubject.onNext(!(payment.cardSchemeObject?.isPaidScheme ?? false))
            feeSubject.onNext(payment.cardSchemeObject?.feeValue ?? "")
            if let location = payment.locationData {
                addressSubject.onNext(location)
            }
            
            let blnceFormatted = String(format: "%.2f", payment.cardSchemeObject?.fee ?? 0.0)
            let balance = "PKR \(blnceFormatted)"
            let text = String.init(format: "screen_yap_confirm_payment_display_text_place_order_for".localized, balance)
            
            buttonTitleSubject.onNext(text)
            //let attributed = NSMutableAttributedString(string: text)
            //            attributed.addAttributes([.foregroundColor: UIColor(Color(hex: "#272262"))], range: NSRange(location: text.count - balance.count, length: balance.count))
        }
        if let cardDetail =  paymentGatewayM.cardDetailObject {
            cardNumberSubject.onNext(cardDetail.cardNumber ?? "")
        }
        localizedStringsSubject.onNext(theStrings)
        
        // TODO: [UMAIR] - Remove this skip once multiple calls issue fixed
        nextSubject.skip(1).withUnretained(self)
            .subscribe(onNext:{ `self`, _ in
                print("next button tapped")
                self.fetchApis()
            }).disposed(by: disposeBag)
        
        
    }
    
    private func fetchApis() {
        
        guard let locationObj = self.paymentGatewayM.locationData else { return }
        
        YAPProgressHud.showProgressHud()
        
        //!!!: check if user isFirstCredit is True then don't call saveAddress api
        if (accountProvider.currentAccountValue.value?.parnterBankStatus == .physicalCardPending || accountProvider.currentAccountValue.value?.parnterBankStatus == .ibanAssigned) && (accountProvider.currentAccountValue.value?.isFirstCredit == true || self.paymentGatewayM.cardSchemeObject?.isPaidScheme == false) {
            //order card api directly
            print("order card api directly")
        } else if (accountProvider.currentAccountValue.value?.parnterBankStatus == .physicalCardPending || accountProvider.currentAccountValue.value?.parnterBankStatus == .ibanAssigned) && (self.paymentGatewayM.cardSchemeObject?.isPaidScheme == true) {
            //create checkout session request and flow
            print("create checkout session request and flow")
            guard let cardObject = self.paymentGatewayM.cardDetailObject else { return }

            let fetchCheckoutSessionRequest = self.transactionRepository.fetchCheckoutSession(amount: String(self.paymentGatewayM.cardSchemeObject?.fee ?? 0), currency: "PKR", sessionId: cardObject.sessionID ?? "")

            let  fetch3DSEnrollmentRequest =     fetchCheckoutSessionRequest.elements().withUnretained(self).flatMapLatest { `self`,  paymentGatewayCheckoutSession -> Observable<Event<PaymentGateway3DSEnrollmentResult>> in
                self.transactionRepository.fetch3DSEnrollment(orderId: paymentGatewayCheckoutSession.order?.id ?? "", beneficiaryID: Int(paymentGatewayCheckoutSession.beneficiaryId) ?? 0, amount: paymentGatewayCheckoutSession.order?.amount ?? "", currency: paymentGatewayCheckoutSession.order?.currency ?? "", sessionID: paymentGatewayCheckoutSession.session?.id ?? "")
            }
            fetchCheckoutSessionRequest.errors().subscribe(onNext: { [weak self] error in
                print("checkout session request error")
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)

            fetch3DSEnrollmentRequest.elements().withUnretained(self).subscribe(onNext: { `self`, paymentGateway3DSEnrollmentResult in
                //TODO: present 3ds webview from ConfirmPayment coordinator.
            }).disposed(by: disposeBag)


            fetch3DSEnrollmentRequest.errors().subscribe(onNext: { [weak self] error in
                print("3ds request error")
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)
        } else {
            //save address and complete flow
            print("save address and complete flow")
            let saveUserAddressRequest = kycRepository.saveUserAddress(addressOne: String(locationObj.formattAdaddress.prefix(50)), addressTwo: String(locationObj.formattAdaddress.prefix(50)), city: locationObj.city, country: locationObj.country, latitude: String(locationObj.latitude), longitude: String(locationObj.longitude))
                    
            saveUserAddressRequest.errors().subscribe(onNext: { error in
                YAPProgressHud.hideProgressHud()
                print("save address error")
            }).disposed(by: disposeBag)
        
        saveUserAddressRequest.elements().subscribe(onNext:{
            print("save address response: \($0)")
        }).disposed(by: disposeBag)
            
            guard let cardObject = self.paymentGatewayM.cardDetailObject else { return }
        
            let paymentGatewayCheckoutSessionRequest = saveUserAddressRequest.elements().withUnretained(self).flatMapLatest { `self`, newAccount -> Observable<Event<PaymentGatewayCheckoutSession>> in
                
                let fetchCheckoutSessionRequest = self.transactionRepository.fetchCheckoutSession(amount: String(self.paymentGatewayM.cardSchemeObject?.fee ?? 0), currency: "PKR", sessionId: cardObject.sessionID ?? "")
                return  fetchCheckoutSessionRequest
            }.share()
            
            let  fetch3DSEnrollmentRequest =     paymentGatewayCheckoutSessionRequest.elements().withUnretained(self).flatMapLatest { `self`,  paymentGatewayCheckoutSession -> Observable<Event<PaymentGateway3DSEnrollmentResult>> in
                self.transactionRepository.fetch3DSEnrollment(orderId: paymentGatewayCheckoutSession.order?.id ?? "", beneficiaryID: Int(paymentGatewayCheckoutSession.beneficiaryId) ?? 0, amount: paymentGatewayCheckoutSession.order?.amount ?? "", currency: paymentGatewayCheckoutSession.order?.currency ?? "", sessionID: paymentGatewayCheckoutSession.session?.id ?? "")
            }
            paymentGatewayCheckoutSessionRequest.errors().subscribe(onNext: { [weak self] error in
                print("checkout session request error")
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)
            
            fetch3DSEnrollmentRequest.elements().withUnretained(self).subscribe(onNext: { `self`, paymentGateway3DSEnrollmentResult in
                //TODO: present 3ds webview from ConfirmPayment coordinator.
            }).disposed(by: disposeBag)
            
            
            fetch3DSEnrollmentRequest.errors().subscribe(onNext: { [weak self] error in
                print("3ds request error")
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)
        }
//        } else {
//
//        }
    }
    
    func fetchAddressApi(){
        
    }
    
    
}

extension ConfirmPaymentViewModel {
    struct LocalizedStrings {
        let title: String
        var subTitle: String
        let cardFee: String
        let payWith: String
        let action: String
        
        init() {
            self.init(title: "", subTitle: "", cardFee: "", payWith: "", action: "")
        }
        
        init(title: String,
             subTitle: String,
             cardFee: String,
             payWith: String,
             action: String) {
            self.title = title
            self.subTitle = subTitle
            self.cardFee = cardFee
            self.payWith = payWith
            self.action = action
        }
    }
}
