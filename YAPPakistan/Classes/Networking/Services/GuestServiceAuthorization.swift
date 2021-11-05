//
//  GuestServiceAuthorization.swift
//  Networking
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

class GuestServiceAuthorization: ServiceAuthorizationProviderType {
    private let tokenSubject = BehaviorSubject<String>(value: "")
    private let disposeBag = DisposeBag()

    private var xsrf = "fa142ea6-1784-4c27-87a9-92b90df908f3"

    init() {
        tokenSubject.asObservable().subscribe(onNext: { [weak self] token in
            // self?.xsrf = token
        }).disposed(by: disposeBag)
    }

    var tokenObserver: AnyObserver<String> { tokenSubject.asObserver() }

    var authorizationHeaders: [String: String] {
        if xsrf.isEmpty {
            return [:]
        }

        var headers: [String: String] = [:]
        headers["X-XSRF-TOKEN"] = "fa142ea6-1784-4c27-87a9-92b90df908f3"
        headers["Cookie"] = "XSRF-TOKEN=\("fa142ea6-1784-4c27-87a9-92b90df908f3")"

        return headers
    }
}
