//
//  Service.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol Service {
    func request<T: Codable>(apiClient: APIClient, route: YAPURLRequestConvertible) -> Observable<T>
    func upload<T: Codable>(apiClient: APIClient, documents: [DocumentDataConvertible], route: YAPURLRequestConvertible, progressObserver: AnyObserver<Progress>?, otherFormValues formValues: [String: String]) -> Observable<T>
}
