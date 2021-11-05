//
//  Session.swift
//  YAPKit
//
//  Created by Umer on 18/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

class Session {
    // MARK: Properties

    private var sessionToken: String

    private let disposeBag = DisposeBag()
    private var tokenSubject: BehaviorSubject<String>

    // MARK: Initializer

    public init(sessionToken jwt: String) {
        self.sessionToken = jwt

        tokenSubject = BehaviorSubject(value: jwt)
        tokenSubject.asObservable().subscribe(onNext: { [weak self] jwt in
            self?.sessionToken = jwt
        }).disposed(by: disposeBag)
    }
}

extension Session: ServiceAuthorizationProviderType {
    var tokenObserver: AnyObserver<String> { tokenSubject.asObserver() }

    var authorizationHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(sessionToken)"

        headers["X-XSRF-TOKEN"] = "fa142ea6-1784-4c27-87a9-92b90df908f3"
        headers["Cookie"] = "XSRF-TOKEN=\("fa142ea6-1784-4c27-87a9-92b90df908f3")"

        return headers
    }
}
