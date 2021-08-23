//
//  APIResponseConvertible.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public protocol APIResponseConvertible: Codable {
    var code: Int { get }
    var data: Data { get }
}
