//
//  ExternalCardBeneficiaryRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 18/02/2022.
//

import Foundation

struct ExternalBeneficiaryRequest: Codable {
    let alias: String
    let color: String
    let session: SessionR
}

struct SessionR: Codable {
    let id: String
    let number: String
}
