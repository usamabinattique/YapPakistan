//
//  PINRepository.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 11/07/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol PINRepositoryType: AnyObject {

    func newPassword(username: String, token: String, password: String) -> Observable<Event<String?>>
}

class PINRepository: PINRepositoryType {
    
    private let customerService: CustomerServiceType
    
    init(customerService: CustomerServiceType) {
        self.customerService = customerService
    }

    func newPassword(username: String, token: String, password: String) -> Observable<Event<String?>> {
        return customerService.newPassword(username: username, token: token, password: password).materialize()
    }
}
