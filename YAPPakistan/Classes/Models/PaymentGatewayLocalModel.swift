//
//  PaymentGatewayLocalModel.swift
//  YAPPakistan
//
//  Created by Umair  on 21/02/2022.
//

import Foundation

public class PaymentGatewayLocalModel: NSObject {
    
    var cardDetailObject: CommonWebViewM?
    var cardSchemeObject: KYCCardsSchemeM?
    var locationData: LocationModel?
    var beneficiary: ExternalPaymentCard?
    
    init(cardDetailObject: CommonWebViewM? = nil, cardSchemeObject: KYCCardsSchemeM? = nil, locationData: LocationModel? = nil, beneficiary: ExternalPaymentCard? = nil) {
        self.cardDetailObject = cardDetailObject
        self.cardSchemeObject = cardSchemeObject
        self.locationData = locationData
        self.beneficiary = beneficiary
    }
}
