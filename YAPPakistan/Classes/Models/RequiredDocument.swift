//
//  RequiredDocument.swift
//  YAPPakistan
//
//  Created by Yasir on 28/06/2022.
//

import Foundation

public enum MissingDocumentType: String {
    case cnicCopy = "REQUIRED_CNIC_COPY"
    case selfie = "REQUIRED_SELFIE"
    
}

public struct RequiredDocument: Codable {
    
    let documentName: String
    let DocumentType: String
    let uploaded: Bool
    
    public var documentType: MissingDocumentType {
        return MissingDocumentType(rawValue: DocumentType) ?? .selfie
    }

    enum CodingKeys: String, CodingKey {

        case documentName
        case DocumentType
        case uploaded
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        documentName = try values.decodeIfPresent(String.self, forKey: .documentName) ?? ""
        DocumentType = try values.decodeIfPresent(String.self, forKey: .DocumentType) ?? ""
        uploaded = try values.decodeIfPresent(Bool.self, forKey: .uploaded) ?? false
    }

}
