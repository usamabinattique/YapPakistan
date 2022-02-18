//
//  KYCRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 27/09/2021.
//

import Foundation
import RxSwift

protocol KYCRepositoryType {
    func fetchDocument(byType documentType: String) -> Observable<Event<Document?>>
    func detectCNICInfo(_ documents: [(data: Data, format: String)],
                        progressObserver: AnyObserver<Progress>?) -> Observable<Event<CNICOCR?>>
    func performNadraVerification(cnic: String, dateOfIssuance: String) -> Observable<Event<CNICInfo?>>
    func saveDocuments(_ documents: [(data: Data, format: String)],
                       documentType: String,
                       identityNo: String,
                       nationality: String,
                       fullName: String,
                       gender: String,
                       dob: String,
                       dateIssue: String,
                       dateExpiry: String) -> Observable<Event<String?>>
    func getMotherMaidenNames() -> Observable<Event<[String]>>
    func getCityOfBirthNames() -> Observable<Event<[String]>>
    func verifySecretQuestions(motherMaidenName: String, cityOfBirth: String ) -> Observable<Event<Bool>>
    func uploadSelfie(_ selfie: (data: Data, format: String)) -> Observable<Event<[String: String?]>>
    func setCardName(cardName: String) -> Observable<Event<String?>>
    func getCities() -> Observable<Event<[Cities]>>
    func saveUserAddress(address: String,
                         city: String,
                         country: String,
                         postCode: String,
                         latitude: String,
                         longitude: String ) -> Observable<Event<String?>>
    
    func fetchCardScheme() -> Observable<Event<[KYCCardsSchemeM]>>
}

class KYCRepository: KYCRepositoryType {
    private let customersService: CustomersService
    private let cardsService: CardsService

    init(customersService: CustomersService, cardsService: CardsService) {
        self.customersService = customersService
        self.cardsService = cardsService
    }

    func fetchDocument(byType documentType: String) -> Observable<Event<Document?>> {
        return customersService.fetchDocument(byType: documentType).materialize()
    }

    func detectCNICInfo(_ documents: [(data: Data, format: String)],
                        progressObserver: AnyObserver<Progress>? = nil) -> Observable<Event<CNICOCR?>> {
        return customersService.detectCNICInfo(documents, progressObserver: progressObserver).materialize()
    }

    func performNadraVerification(cnic: String, dateOfIssuance: String) -> Observable<Event<CNICInfo?>> {
        return customersService.performNadraVerification(cnic: cnic, dateOfIssuance: dateOfIssuance).materialize()
    }

    func saveDocuments(_ documents: [(data: Data, format: String)],
                       documentType: String,
                       identityNo: String,
                       nationality: String,
                       fullName: String,
                       gender: String,
                       dob: String,
                       dateIssue: String,
                       dateExpiry: String) -> Observable<Event<String?>> {
        return customersService.saveDocuments(documents, documentType: documentType,
                                              identityNo: identityNo, nationality: nationality,
                                              fullName: fullName, gender: gender, dob: dob,
                                              dateIssue: dateIssue, dateExpiry: dateExpiry).materialize()
    }

    func getMotherMaidenNames() -> Observable<Event<[String]>> {
        return customersService.getMotherMaidenNames().materialize()
    }

    func getCityOfBirthNames() -> Observable<Event<[String]>> {
        return customersService.getCityOfBirthNames().materialize()
    }

    func verifySecretQuestions(motherMaidenName: String, cityOfBirth: String ) -> Observable<Event<Bool>> {
        return customersService
            .verifySecretQuestions(motherMaidenName:motherMaidenName, cityOfBirth: cityOfBirth )
            .materialize()
    }

    func uploadSelfie(_ selfie: (data: Data, format: String)) -> Observable<Event<[String: String?]>> {
        return customersService.uploadSelfie(selfie).materialize()
    }

    func setCardName(cardName: String) -> Observable<Event<String?>> {
        return customersService.setCardName(cardName: cardName).materialize()
    }

    func getCities() -> Observable<Event<[Cities]>> {
        return customersService.getCities().materialize()
    }

    func saveUserAddress(address: String,
                         city: String,
                         country: String,
                         postCode: String,
                         latitude: String,
                         longitude: String ) -> Observable<Event<String?>> {
        
        //TODO: [YASIR] remove following line
        return Observable.just("Card is saved").materialize()
       
        //TODO: ucomment following line
       /* return cardsService.saveUserAddress(address: address,
                                            city: city,
                                            country: country,
                                            postCode: postCode,
                                            latitude: latitude,
                                            longitude: longitude).materialize() */
    }
    
    func fetchCardScheme() -> Observable<Event<[KYCCardsSchemeM]>> {
        return cardsService.getCardsScheme().materialize()
    }
    
    func fetchCardBenefits(cardType type: SchemeType) -> Observable<Event<[KYCCardBenefitsM]>> {
        return cardsService.getCardBenefits(scheme: type).materialize()
    }
}
