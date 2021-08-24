//
//  AuthenticationInterceptor.swift
//  Authentication
//
//  Created by Muhammad Hassan on 24/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol AuthenticationInterceptor {
    func intercept(response: APIResponseConvertible) -> Observable<Event<APIResponseConvertible>>
}
