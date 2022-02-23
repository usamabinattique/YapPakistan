//
//  PaymentGatewayLocalModel.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

public class PaymentGatewayLocalModel: NSObject {
    
    var beneficiaryId: String?
    var cardDetailObject: CommonWebViewM?
    var cardSchemeObject: KYCCardsSchemeM?
    var locationData: LocationModel?
    
    init(beneficiaryId: String? = nil, cardDetailObject: CommonWebViewM? = nil, cardSchemeObject: KYCCardsSchemeM? = nil, locationData: LocationModel? = nil) {
        self.beneficiaryId = beneficiaryId
        self.cardDetailObject = cardDetailObject
        self.cardSchemeObject = cardSchemeObject
        self.locationData = locationData
    }
}
