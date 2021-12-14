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
}

class CardsRepository: CardsRepositoryType {

    private let cardsService: CardsServiceType

    init(cardsService: CardsServiceType) {
        self.cardsService = cardsService
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
}
