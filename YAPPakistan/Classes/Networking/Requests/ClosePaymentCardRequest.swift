//
//  ClosePaymentCardRequest.swift
//  YAPPakistan
//
//  Created by Umair  on 28/12/2021.
//

import Foundation

struct ClosePaymentCardRequest: Codable {
    let cardSerialNumber: String
    let hotListReason: String
}
