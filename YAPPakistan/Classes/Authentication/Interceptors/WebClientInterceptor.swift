//
//  WebClientInterceptor.swift
//  Authentication
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public class WebClientInterceptor: AuthenticationInterceptor {
    public func intercept(response: APIResponseConvertible) -> Observable<Event<APIResponseConvertible>> {
        let subject = BehaviorSubject<APIResponseConvertible>(value: response)

        if response.code == 401 {
            subject.onError(AuthenticationError.expiredJWT)
        }

        return subject.materialize()
    }

    public init() { }
}
