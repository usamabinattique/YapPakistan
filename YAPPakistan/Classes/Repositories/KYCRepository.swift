//
//  KYCRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 27/09/2021.
//

import Foundation
import RxSwift

class KYCRepository {
    private let customersService: CustomersService

    init(customersService: CustomersService) {
        self.customersService = customersService
    }

    func fetchDocument(byType documentType: String) -> Observable<Event<Document?>> {
        return customersService.fetchDocument(byType: documentType).materialize()
    }
}
