//
//  SplashRepository.swift
//  YAPKit
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol SplashRepositoryType {
    func fetchXSRFToken() -> Observable<Event<Void>>
}

public class SplashRepository: SplashRepositoryType {
    private let service: XSRFServiceType
    public init(service: XSRFServiceType) {
        self.service = service
    }
    public func fetchXSRFToken() -> Observable<Event<Void>> {
        return service.fetchXSRFToken().map { _ in () }.materialize()
    }
}
