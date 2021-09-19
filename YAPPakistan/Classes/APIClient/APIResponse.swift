//
//  APIResponse.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct APIResponse: APIResponseConvertible {
    public let code: Int
    public let data: Data

    public init(code: Int, data: Data) {
        self.code = code
        self.data = data
    }
}
