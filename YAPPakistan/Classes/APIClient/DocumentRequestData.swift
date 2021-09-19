//
//  DocumentRequestData.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct DocumentRequestData: DocumentDataConvertible {
    public var data: Data
    public var name: String
    public var fileName: String
    public var mimeType: String
}
