//
//  Session.swift
//  YAPKit
//
//  Created by Umer on 18/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

public class Session {

    // MARK: Properties

    private let guestToken: String
    private var sessionToken: String
    
    private let disposeBag = DisposeBag()
    private var tokenSubject: BehaviorSubject<String>

    public var tokenObserver: AnyObserver<String> { tokenSubject.asObserver() }

    // MARK: Initializer

    public init(guestToken xsrf: String, sessionToken jwt: String) {
        self.guestToken = xsrf
        self.sessionToken = jwt

        tokenSubject = BehaviorSubject(value: jwt)
        tokenSubject.asObservable().subscribe(onNext: { [weak self] jwt in
            self?.sessionToken = jwt
        }).disposed(by: disposeBag)
    }
}

extension Session: ServiceAuthorizationProviderType {
    public var authorizationHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["X-XSRF-TOKEN"] = guestToken
        headers["Cookie"] = "XSRF-TOKEN=\(guestToken)"
        headers["Authorization"] = "Bearer \(sessionToken)"

        return headers
    }
}
