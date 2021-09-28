//
//  DocumentUploadRequest.swift
//  YAP
//
//  Created by MHS on 05/09/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation

struct DocumentUploadRequest: DocumentDataConvertible {
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String
}
