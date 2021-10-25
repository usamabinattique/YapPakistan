//
//  SessionProvider.swift
//  YAPKit
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

protocol SessionProviderType {
    func makeUserSession(jwt: String) -> Session
}

class SessionProvider: SessionProviderType {
    func makeUserSession(jwt: String) -> Session {
        return Session(sessionToken: jwt)
    }
}
