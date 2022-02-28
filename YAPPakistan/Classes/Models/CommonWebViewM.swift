//
//  CommonWebViewM.swift
//  YAPPakistan
//
//  Created by Umair  on 15/02/2022.
//

import Foundation

class CommonWebViewM: Codable {
    
    let nickName: String?
    let cardNumber: String?
    let sessionID: String?
    let color: String?
    let saveCardDetails: Bool?
    let errors: String?
    
    var session: SessionCardInput? {
        return SessionCardInput(id: sessionID,number: cardNumber)
    }
    
    enum CodingKeys: String, CodingKey {
        case nickName = "alias"
        case cardNumber = "number"
        case sessionID
        case color
        case saveCardDetails
        case errors
    }
    
    public required init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        
        self.nickName = (try? data.decode(String?.self, forKey: .nickName)) ?? ""
        self.cardNumber = (try? data.decode(String?.self, forKey: .cardNumber)) ?? ""
        self.sessionID = (try? data.decode(String?.self, forKey: .sessionID)) ?? ""
        self.color = (try? data.decode(String?.self, forKey: .color)) ?? ""
        self.saveCardDetails = (try? data.decode(Bool?.self, forKey: .saveCardDetails)) ?? false
        self.errors = (try? data.decode(String?.self, forKey: .errors)) ?? ""
    }
    
    init(nickName: String? = "", cardNumber: String? = "", sessionID: String? = "", color: String? = "", saveCardDetails: Bool? = false, errors: String? = ""){
        self.nickName = nickName
        self.cardNumber = cardNumber
        self.sessionID = sessionID
        self.color = color
        self.saveCardDetails = saveCardDetails
        self.errors = errors
    }
    
     class SessionCardInput: Codable {
        var id: String?
        var number: String?
        
        init(id: String?, number: String?) {
            self.id = id
            self.number = number
        }
    }
}
