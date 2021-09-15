//
//  Credentials.swift
//  App
//
//  Created by Hussaan S on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct Credentials: Codable {
    public let username: String
    public let passcode: String
    
    public init(username: String,
                passcode: String) {
        self.username = username
        self.passcode = passcode
    }
}
