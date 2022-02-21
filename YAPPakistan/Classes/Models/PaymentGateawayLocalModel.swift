//
//  PaymentGateawayLocalModel.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

public class PaymentGateawayLocalModel: NSObject {
    
    var beneficiaryId: String?
    var cardDetailObject: CommonWebViewM?
    var cardSchemeObject: KYCCardsSchemeM?
    
    init(beneficiaryId: String? = nil, cardDetailObject: CommonWebViewM? = nil, cardSchemeObject: KYCCardsSchemeM? = nil) {
        self.beneficiaryId = beneficiaryId
        self.cardDetailObject = cardDetailObject
        self.cardSchemeObject = cardSchemeObject
    }
}
