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
}

class KYCRepository: KYCRepositoryType {
    private let customersService: CustomersService

    init(customersService: CustomersService) {
        self.customersService = customersService
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
}
