//
//  KYCRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 27/09/2021.
//

import Foundation
import RxSwift
import UIKit

protocol KYCRepositoryType {
    func fetchDocument(byType documentType: String) -> Observable<Event<Document?>>
    func detectCNICInfo(_ documents: [(fileName: String, data: Data, format: String)],
                        progressObserver: AnyObserver<Progress>?) -> Observable<Event<CNICOCR?>>
    func performNadraVerification(cnic: String, dateOfIssuance: String) -> Observable<Event<CNICInfo?>>
    func saveDocuments(_ documents: [(data: Data, format: String)],
                       documentType: String,
                       identityNo: String,
                       nationality: String,
                       fullName: String,
                       fatherName: String,
                       gender: String,
                       dob: String,
                       dateIssue: String,
                       dateExpiry: String) -> Observable<Event<String?>>
    func getMotherMaidenNames() -> Observable<Event<[String]>>
    func getCityOfBirthNames() -> Observable<Event<[String]>>
    func verifySecretQuestions(motherMaidenName: String, cityOfBirth: String ) -> Observable<Event<Bool>>
    func uploadSelfie(_ selfie: (data: Data, format: String)) -> Observable<Event<[String: String?]>>
    func uploadSelfieComparison(_ selfie: (data: Data, format: String), isCompared: Bool) -> Observable<Event<[String: String?]>>
    func setCardName(cardName: String) -> Observable<Event<String?>>
    func getCities() -> Observable<Event<[Cities]>>
    func saveUserAddress(addressOne: String,
                         addressTwo: String,
                         city: String,
                         country: String,
                         latitude: String,
                         longitude: String ) -> Observable<Event<String?>>
    
    func fetchCardScheme() -> Observable<Event<[KYCCardsSchemeM]>>
    func generateIBAN(isSelfieMatched: Bool) -> Observable<Event<[Account]>>
    func verifyFaceOCR(_ data: Data, fileName: String, mimeType: String) -> Observable<Event<Bool>>
    func idCardReupload(_ documents: [(fileName: String, data: Data, format: String)],
                                           progressObserver: AnyObserver<Progress>?, issueDate: String, cnic: String) -> Observable<Event<String?>>
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

    func detectCNICInfo(_ documents: [(fileName: String, data: Data, format: String)],
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
                       fatherName: String,
                       gender: String,
                       dob: String,
                       dateIssue: String,
                       dateExpiry: String) -> Observable<Event<String?>> {
        return customersService.saveDocuments(documents, documentType: documentType,
                                              identityNo: identityNo, nationality: nationality,
                                              fullName: fullName, fatherName: fatherName, gender: gender, dob: dob,
                                              dateIssue: dateIssue, dateExpiry: dateExpiry).materialize()
    }
    
    func idCardReupload(_ documents: [(fileName: String, data: Data, format: String)],
                        progressObserver: AnyObserver<Progress>? = nil, issueDate: String, cnic: String) -> Observable<Event<String?>> {
        return customersService.idCardReupload(documents, progressObserver: progressObserver, issueDate: issueDate, cnic: cnic).materialize()
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
    
    func uploadSelfieComparison(_ selfie: (data: Data, format: String), isCompared: Bool) -> Observable<Event<[String: String?]>> {
        return customersService.uploadSelfieComparison(selfie, isCompared: isCompared).materialize()
    }

    func setCardName(cardName: String) -> Observable<Event<String?>> {
        return customersService.setCardName(cardName: cardName).materialize()
    }

    func getCities() -> Observable<Event<[Cities]>> {
        return customersService.getCities().materialize()
    }

    func saveUserAddress(addressOne: String,
                         addressTwo: String,
                         city: String,
                         country: String,
                         latitude: String,
                         longitude: String ) -> Observable<Event<String?>> {
        
       return cardsService.saveUserAddress(addressOne: addressOne,
                                           addressTwo: addressTwo,
                                            city: city,
                                            country: country,
                                            latitude: latitude,
                                            longitude: longitude).materialize()
    }
    
    func fetchCardScheme() -> Observable<Event<[KYCCardsSchemeM]>> {
        return cardsService.getCardsScheme().materialize()
    }
    
    func fetchCardBenefits(cardType type: SchemeType) -> Observable<Event<[KYCCardBenefitsM]>> {
        return cardsService.getCardBenefits(scheme: type).materialize()
    }
    
    func generateIBAN(isSelfieMatched: Bool) -> Observable<Event<[Account]>> {
        return customersService.generateIBAN(isSelfieMatched: isSelfieMatched).materialize()
    }
    
    func verifyFaceOCR(_ data: Data, fileName: String, mimeType: String) -> Observable<Event<Bool>> {
        return customersService.verifyFaceOCR(data, fileName: fileName, mimeType: mimeType).materialize()
    }
}
