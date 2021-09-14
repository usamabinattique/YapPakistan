//
//  SessionProvider.swift
//  YAPKit
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

public protocol SessionProviderType {
    func makeUserSession(jwt: String) -> Session
}

public class SessionProvider: SessionProviderType {
    private let xsrfToken: String

    public init(xsrfToken: String) {
        self.xsrfToken = xsrfToken
    }

    public func makeUserSession(jwt: String) -> Session {
        return Session(guestToken: xsrfToken, sessionToken: jwt)
    }
}
