//
//  UploadingDocumentsValidator.swift
//  YAPPakistan
//
//  Created by Awais on 27/04/2022.
//

import Foundation


enum UploadingDocumentError: Error {
    case malicious
    case sizeExceed
    
    public var errorDescription: String? {
        switch self {
        case .malicious:
            return "error_document_validation_malicious".localized
        case .sizeExceed:
            return "error_document_validation_size_exceed".localized
        }
    }
}

extension UploadingDocumentError: LocalizedError { }


protocol UploadingDocumentValidator {
    func validate() throws
}

public class UploadingImageValiadtor: UploadingDocumentValidator {
    
    private let maxFileSize = 26_214_400 // 25MB
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func validate() throws {
        guard UIImage(data: data) != nil else { throw UploadingDocumentError.malicious }
        guard data.count <= maxFileSize else { throw UploadingDocumentError.sizeExceed }
    }
}
