//
//  CustomerPersonalDetailResponse.swift
//  YAPPakistan
//
//  Created by Umair  on 26/04/2022.
//

import Foundation

public struct CustomerPersonalDetailResponse: Codable {
    let fullName: String
    let phoneNumber: String
    let email: String
    let kycAddress: String?
    let personalAddress: String?
    let address: String
    let cnicNumber: String
    let cnicExpiry: String
    let cnicExpired: Bool
    let emailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case phoneNumber
        case email
        case kycAddress
        case personalAddress
        case address
        case cnicNumber
        case cnicExpiry
        case cnicExpired
        case emailVerified
    }
}
