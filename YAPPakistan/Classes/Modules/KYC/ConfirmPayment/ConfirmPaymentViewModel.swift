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
    var pollACSResultObserver: AnyObserver<Void> { get }
    var enteredCVV: AnyObserver<String> { get }
    var doitLaterObserver: AnyObserver<Void> { get }
}

protocol ConfirmPaymentViewModelOutputs {
    var close: Observable<Void> { get }
    var next: Observable<Int> { get }
    var error: Observable<String> { get }
    var isEnabled: Observable<Bool> { get }
    var completedSteps: Observable<Int> { get }
    var localizedStrings: Observable<ConfirmPaymentViewModel.LocalizedStrings> { get }
    var edit: Observable<Void> { get }
    var cardImage: Observable<UIImage?> { get }
    var isPaid: Observable<Bool> { get }
    var cardFee: Observable<String> { get }
    var fedFee: Observable<String> { get }
    var orderTotalFee: Observable<String> { get }
    var cardNumber: Observable<String> { get }
    var address: Observable<LocationModel> { get }
    var buttonTitle: Observable<String> { get }
    var html: Observable<String> { get }
    var pollACSResult: Observable<Void> { get }
    var topupComplete: Observable<Void> { get }
    var showCVV: Observable<Void> { get }
    var doItLater: Observable<Void> { get }
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
    var pollACSResultObserver: AnyObserver<Void> { return pollACSResultSubject.asObserver() }
    var enteredCVV: AnyObserver<String> { enteredCVVSubject.asObserver() }
    var doitLaterObserver: AnyObserver<Void> { return doItLaterSubject.asObserver() }
    
    // MARK: Outputs
    var close: Observable<Void> { backSubject.asObservable() }
    var next: Observable<Int> { nextResultSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var isEnabled: Observable<Bool> { isEnabledSubject.asObservable() }
    var completedSteps: Observable<Int> { completedStepsSubject.asObservable() }
    var localizedStrings: Observable<LocalizedStrings> { localizedStringsSubject.asObservable() }
    var edit: Observable<Void> { editSubject.asObservable() }
    var cardImage: Observable<UIImage?> { cardImageSubject.asObservable() }
    var isPaid: Observable<Bool> { isPaidSubject.asObservable() }
    var cardFee: Observable<String> { feeSubject.asObservable() }
    var fedFee: Observable<String> { fedFeeSubject.asObservable() }
    var orderTotalFee: Observable<String> { orderTotalFeeSubject.asObservable() }
    var cardNumber: Observable<String> { cardNumberSubject.asObservable() }
    var address: Observable<LocationModel> { addressSubject.asObservable() }
    var buttonTitle: Observable<String> { buttonTitleSubject.asObservable() }
    var html: Observable<String> { return htmlSubject.asObservable() }
    var pollACSResult: Observable<Void> { return pollACSResultSubject.asObservable() }
    var topupComplete: Observable<Void> { return topupCompleteSubject.asObservable() }
    var showCVV: Observable<Void> { showCVVSubject.asObservable() }
    var doItLater: Observable<Void> { doItLaterSubject.asObservable() }
    
    // MARK: Subjects
    private let doItLaterSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let nextSubject = PublishSubject<Void>()
    private let nextResultSubject = PublishSubject<Int>()
    private let errorSubject = PublishSubject<String>()
    private let isEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let completedStepsSubject = BehaviorSubject<Int>(value: 0)
    private let localizedStringsSubject = BehaviorSubject(value: LocalizedStrings())
    private let editSubject = PublishSubject<Void>()
    private let cardImageSubject = ReplaySubject<UIImage?>.create(bufferSize: 1)
    private let isPaidSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let feeSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let fedFeeSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let orderTotalFeeSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let cardNumberSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let addressSubject = ReplaySubject<LocationModel>.create(bufferSize: 1)
    private let buttonTitleSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let htmlSubject = PublishSubject<String>()
    private let pollACSResultSubject = PublishSubject<Void>()
    private let topupCompleteSubject = PublishSubject<Void>()
    private let showCVVSubject = PublishSubject<Void>()
    private let enteredCVVSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    //private let paymentGatewayM: PaymentGatewayLocalModel!
    private let kycRepository: KYCRepository
    private let transactionRepository: TransactionsRepository
    private var accountProvider: AccountProvider!
    private var checkoutSessionObject: PaymentGatewayCheckoutSession?
    private var gatewayLocalM : PaymentGatewayLocalModel?
    
    init(accountProvider: AccountProvider, kycRepository: KYCRepository, transactionRepository: TransactionsRepository, paymentGatewayObj: PaymentGatewayLocalModel? = nil){
        
        self.gatewayLocalM = paymentGatewayObj
        self.accountProvider = accountProvider
        
        self.kycRepository = kycRepository
        self.transactionRepository = transactionRepository
        
        
        var theStrings = LocalizedStrings(title: "screen_yap_confirm_payment_display_text_toolbar_title".localized, subTitle: "screen_yap_confirm_payment_display_text_toolbar_subtitle".localized,cardFee: "screen_yap_confirm_payment_display_text_Card_fee".localized, payWith: "screen_yap_confirm_payment_display_text_pay_with".localized, action: "Place order for PKR 1,000")
        //    localizedStringsSubject.onNext(strings)
        if let payment = gatewayLocalM {
            let cardImageName = gatewayLocalM?.cardSchemeObject?.scheme == .Mastercard ? "payment_card" : "image_payment_card_white_paypak"
            cardImageSubject.onNext(UIImage(named: cardImageName, in: .yapPakistan))
            theStrings.subTitle = gatewayLocalM?.cardSchemeObject?.scheme == .Mastercard ? "screen_kyc_card_scheme_title_mastercard".localized : "screen_yap_confirm_payment_display_text_toolbar_subtitle".localized
            isPaidSubject.onNext(!(gatewayLocalM?.cardSchemeObject?.isPaidScheme ?? false))
            feeSubject.onNext(gatewayLocalM?.cardSchemeObject?.feeValue ?? "")
            if let location = self.gatewayLocalM?.locationData {
                addressSubject.onNext(location)
            }
            
            fedFeeSubject.onNext(String(format: "PKR %.2f", gatewayLocalM?.cardSchemeObject?.fedFee ?? 0.0))
            orderTotalFeeSubject.onNext(String(format: "PKR %.2f", gatewayLocalM?.cardSchemeObject?.totalFee ?? 0.0))
            
            let text = String.init(format: "screen_yap_confirm_payment_display_text_place_order_for".localized)
            buttonTitleSubject.onNext(text)
        }
        
        
//        if let cardDetail =  cardSchemeOBJ.cardDetailObject {
//            cardNumberSubject.onNext(cardDetail.cardNumber ?? "")
//        } else {
//            cardNumberSubject.onNext(paymentGatewayM.beneficiary?.maskedNumberWithAesteric ?? "")
//        }
        
        
        localizedStringsSubject.onNext(theStrings)
        
        nextSubject.withUnretained(self)
            .subscribe(onNext:{ `self`, _ in
                self.fetchApis()
            }).disposed(by: disposeBag)
    }
    
    private func fetchApis() {
        YAPProgressHud.showProgressHud()
        fetchSaveAddressApi()
    }
    
    //MARK: - Apis helper methods
    
    private func fetchSaveAddressApi() {
        guard let locationObj = self.gatewayLocalM?.locationData else { return }
        let saveUserAddressRequest = kycRepository.saveUserAddress(addressOne: String(locationObj.formattAdaddress.prefix(50)), addressTwo: String(locationObj.formattAdaddress.prefix(50)), city: locationObj.city, country: locationObj.country, latitude: String(locationObj.latitude), longitude: String(locationObj.longitude))
        
        saveUserAddressRequest.elements().withUnretained(self)
            .subscribe(onNext: { `self`, account in
                self.fetchOrderCardHolderApi()
            })
            .disposed(by: disposeBag)
        
        saveUserAddressRequest.errors().subscribe(onNext: { [weak self] error in
            self?.errorSubject.onNext(error.localizedDescription)
            YAPProgressHud.hideProgressHud()
            print("save address error")
        }).disposed(by: disposeBag)
    }
    
    func fetchOrderCardHolderApi() {
        
        let cardOrderRequest = transactionRepository.createCardHolder(cardScheme: self.gatewayLocalM?.cardSchemeObject?.schemeName ?? "", fee: String(self.gatewayLocalM?.cardSchemeObject?.fee ?? 0))


        cardOrderRequest.elements().subscribe(onNext: { [unowned self] responseObj in
            YAPProgressHud.hideProgressHud()
            self.accountProvider.refreshAccount().bind(to: self.topupCompleteSubject).disposed(by: self.disposeBag)

        }).disposed(by: disposeBag)

        cardOrderRequest.errors()
            .do(onNext:{ _ in
                YAPProgressHud.hideProgressHud()
            })
            .map {
                $0.localizedDescription
            }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
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
