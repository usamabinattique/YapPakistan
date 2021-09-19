//
//  APIClient.swift
//  Networking
//
//  Created by Zain on 17/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

public typealias YAPURLRequestConvertible = URLRequestConvertible
public typealias YAPHTTPMethod = HTTPMethod

public protocol APIClient {
    func request(route: YAPURLRequestConvertible) -> Observable<APIResponseConvertible>
    func upload(documents: [DocumentDataConvertible],
                route: YAPURLRequestConvertible,
                progressObserver: AnyObserver<Progress>?,
                otherFormValues formValues: [String: String]) -> Observable<APIResponseConvertible>
}
