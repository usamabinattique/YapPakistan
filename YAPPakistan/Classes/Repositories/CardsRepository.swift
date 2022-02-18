//
//  CardsRepository.swift
//  YAPPakistan
//
//  Created by Sarmad on 15/11/2021.
//

import Foundation
import RxSwift

protocol CardsRepositoryType: AnyObject {
    func getCards() -> Observable<Event<[PaymentCard]?>>
    func getCardDetail(cardSerialNumber: String) -> Observable<Event<CardDetails?>>
    func setPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>>
    func configFreezeUnfreezeCard(cardSerialNumber: String) -> Observable<Event<String?>>
    func configAllowAtm(cardSerialNumber: String) -> Observable<Event<String?>>
    func configRetailPayment(cardSerialNumber: String) -> Observable<Event<String?>>
    func verifyCardPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>>
    func changeCardPin(oldPin: String,
                       newPin: String,
                       confirmPin: String,
                       cardSerialNumber: String) -> Observable<Event<String?>>
    func setCardName(cardName: String, cardSerialNumber: String) -> Observable<Event<String?>>
    func forgotCardPin(newPin: String,
                       token: String,
                       cardSerialNumber: String) -> Observable<Event<String?>>
    func verifyPasscode(passcode: String) -> Observable<Event<String?>>
    func generateOTP(action: OTPActions) -> Observable<Event<String?>>
    // func verifyOTP(action: OTPActions, otp: String) -> Observable<Event<String?>>
    func closeCard(cardSerialNumber: String, reason: String) -> Observable<Event<String?>>
    func getHelpLineNumber() -> Observable<Event<String?>>
    func getPhysicalCardAddress() -> Observable<Event<Address?>>
    func reorderDebitCard(cardSerialNumber: String,
                          address: String,
                          city: String,
                          country: String,
                          postCode: String,
                          latitude: String,
                          longitude: String) -> Observable<Event<String?>>
    func fetchReorderFee() -> Observable<Event<CardReorderFee?>>
    func externalCardBeneficiary(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<Event<ExternalPaymentCard?>>
}

class CardsRepository: CardsRepositoryType {

    private let cardsService: CardsServiceType
    private let customerService: CustomerServiceType
    private let messagesService: MessagesServiceType
    private let transactionsService: TransactionsServiceType

    init(cardsService: CardsServiceType,
         customerService: CustomerServiceType,
         messagesService: MessagesServiceType,
         transactionsService: TransactionsServiceType) {
        self.cardsService = cardsService
        self.customerService = customerService
        self.messagesService = messagesService
        self.transactionsService = transactionsService
    }

    public func getCards() -> Observable<Event<[PaymentCard]?>> {
        cardsService.getCards().materialize()
    }

    func getCardDetail(cardSerialNumber: String) -> Observable<Event<CardDetails?>> {
        cardsService.getCardDetail(cardSerialNumber: cardSerialNumber).materialize()
    }

    public func setPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>> {
        cardsService.setPin(cardSerialNumber: cardSerialNumber, pin: pin).materialize()
    }

    func configFreezeUnfreezeCard(cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.configFreezeUnfreezeCard(cardSerialNumber: cardSerialNumber).materialize()
    }

    func configAllowAtm(cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.configAllowAtm(cardSerialNumber: cardSerialNumber).materialize()
    }

    func configRetailPayment(cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.configRetailPayment(cardSerialNumber: cardSerialNumber).materialize()
    }

    func verifyCardPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>> {
        cardsService.verifyCardPin(cardSerialNumber: cardSerialNumber, pin: pin).materialize()
    }

    func changeCardPin(oldPin: String,
                       newPin: String,
                       confirmPin: String,
                       cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.changeCardPin(oldPin: oldPin,
                                   newPin: newPin,
                                   confirmPin: confirmPin,
                                   cardSerialNumber: cardSerialNumber).materialize()
    }

    func setCardName(cardName: String, cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.setCardName(cardName: cardName, cardSerialNumber: cardSerialNumber).materialize()
    }

    func forgotCardPin(newPin: String, token: String, cardSerialNumber: String) -> Observable<Event<String?>> {
        cardsService.forgotCardPin(newPin: newPin, token: token, cardSerialNumber: cardSerialNumber).materialize()
    }

    func verifyPasscode(passcode: String) -> Observable<Event<String?>> {
        customerService.verifyPasscode(passcode: passcode).materialize()
    }
    
    //External card beneficiary for topup
    func externalCardBeneficiary(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<Event<ExternalPaymentCard?>> {
        customerService.fetchExternalCardBeneficiaries(alias: alias, color: color, sessionId: sessionId, cardNumber: cardNumber).materialize()
    }

    //"action": "FORGOT_CARD_PIN"
    func generateOTP(action: OTPActions) -> Observable<Event<String?>> {
        messagesService.generateOTP(action: action.rawValue).materialize()
    }
//    func verifyOTP(action: OTPActions, otp: String) -> Observable<Event<String?>> {
//        messagesService.verifyOTP(action: action.rawValue, otp: otp).materialize()
//    }
    
    public func closeCard(cardSerialNumber: String, reason: String) -> Observable<Event<String?>> {
        return self.cardsService.closeCard(cardSerialNumber, reason: reason).materialize()
    }
    
    public func getHelpLineNumber() -> Observable<Event<String?>> {
        return messagesService.getHelplineNumber().materialize()
    }

    func getPhysicalCardAddress() -> Observable<Event<Address?>> {
        cardsService.getPhysicalCardAddress().materialize()
    }

    func reorderDebitCard(cardSerialNumber: String,
                          address: String,
                          city: String,
                          country: String,
                          postCode: String,
                          latitude: String,
                          longitude: String) -> Observable<Event<String?>> {
        cardsService.reorderDebitCard(cardSerialNumber: cardSerialNumber,
                                      address: address,
                                      city: city,
                                      country: country,
                                      postCode: postCode,
                                      latitude: latitude,
                                      longitude: longitude).materialize()
    }

    func fetchReorderFee() -> Observable<Event<CardReorderFee?>> {
        transactionsService.fetchReorderFee().materialize()
    }
}

enum OTPActions: String {
    case forgotCardPin = "FORGOT_CARD_PIN"
}
