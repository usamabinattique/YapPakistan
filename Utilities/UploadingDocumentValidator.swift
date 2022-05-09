//
//  UploadingDocumentValidator.swift
//  Adjust
//
//  Created by Awais on 26/04/2022.
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


// MARK: - String Localizable

public extension String {
    var localized: String {
        return  AppTranslation.shared.translation(forKey: self)
    }
}

public class AppTranslation {
    public static let shared = AppTranslation()
//    private let translationEntityHandler = TranslationEntityHandler()
    
    private init () { }
    
    public func translation(forKey key: String, comment: String = "") -> String {
//        if let translation = translationEntityHandler.translation(forKey: key) {
//            return translation
//        }
        return translationBundel.localizedString(forKey: key, value: nil, table: nil)
    }
}

var translationBundel: Bundle {
    return Bundle(for: AppTranslation.self)
}
