//
//  KYCDocument.swift
//  YAPPakistan
//
//  Created by Tayyab on 27/09/2021.
//

import Foundation

public enum DocumentType {
    static let cnic = "CNIC"
}

public struct KYCDocument: Codable {
    public let imageText: String
    public let documentType: String
    public let pages: [DocumentPage]
}

public struct DocumentPage: Codable {
    let pageNo: Int
    let imageURL: String
    let contentType: String
    let fileName: String
}

public struct Document: Codable {
    public let documentType: String
    public let nationality, dateExpiry, dateIssue, dob: String
    public let gender: String
    public let active: Bool
    public let customerDocuments: [CustomerDocument]?
}

extension Document {
   public var isExpired: Bool {
        return (DateFormatter.serverReadableDateFromatter.date(from: dateExpiry) ?? Date()) < Date()
    }
}

public struct CustomerDocument: Codable {
    public let imageUrl: String?
    public let documentType: String
    public let information: DocumentInformation

    enum CodingKeys: String, CodingKey {
        case imageUrl = "fileName"
        case documentType = "documentType"
        case information = "documentInformation"
    }
}

public struct DocumentInformation: Codable {
    public let fullName: String?
    public let firstName: String?
    public let lastName: String?
    public let identityNumber: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "fullName"
        case firstName = "firstName"
        case lastName = "lastName"
        case identityNumber = "identityNo"
    }
}
