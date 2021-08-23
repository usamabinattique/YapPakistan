//
//  DocumentDataConvertible.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public protocol DocumentDataConvertible: Codable {
    var data: Data { get }
    var name: String { get }
    var fileName: String { get }
    var mimeType: String { get }
}
