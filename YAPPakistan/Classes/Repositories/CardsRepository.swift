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
}
