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
    func setPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>>
}

class CardsRepository: CardsRepositoryType {
    private let cardsService: CardsServiceType

    init(cardsService: CardsServiceType) {
        self.cardsService = cardsService
    }

    public func getCards() -> Observable<Event<[PaymentCard]?>> {
        cardsService.getCards().materialize()
    }

    public func setPin(cardSerialNumber: String, pin: String) -> Observable<Event<String?>> {
        cardsService.setPin(cardSerialNumber: cardSerialNumber, pin: pin).materialize()
    }
}
