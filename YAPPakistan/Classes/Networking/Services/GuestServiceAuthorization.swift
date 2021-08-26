//
//  GuestServiceAuthorization.swift
//  Networking
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

public class GuestServiceAuthorization: ServiceAuthorizationProviderType {
    public var xsrf: String
    private let tokenSubject: BehaviorSubject<String>!
    public var tokenObserver: AnyObserver<String> {  tokenSubject.asObserver()  }
    private let disposeBag = DisposeBag()
    public init(xsrf: String) {
        self.xsrf = xsrf
        tokenSubject = BehaviorSubject(value: xsrf)
        tokenSubject.asObservable().subscribe(onNext: { [weak self] token in
            self?.xsrf = token
        }).disposed(by: disposeBag)
    }
    public var authorizationHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["X-XSRF-TOKEN"] = xsrf
        headers["Cookie"] = "XSRF-TOKEN=\(xsrf)"
        return headers
    }
}
