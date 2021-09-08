//
//  Formatters.swift
//  YAPKit
//
//  Created by Muhammad Hassan on 08/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public func format(iban: String) -> String {
    var chuncks = [String]()
    var chunck = ""
    (0..<iban.count).forEach{
        
        chunck.append(iban[$0])
        
        if $0 != 0, ($0+1) % 4 == 0 {
            chuncks.append(chunck)
            chunck = ""
        }
    }
    
    if chunck.count > 0 {
        chuncks.append(chunck)
    }
    
    return chuncks.joined(separator: " ")
}

public func mask(iban: String) -> String {
    guard iban.count > 15 else { return iban }
    return iban.dropLast(6) + "******"
}

public func mask(mobile: String) -> String {
    var maskedMobileNumber: String = ""
    for _ in 0..<mobile.count - 2 { maskedMobileNumber += "*" }
    return maskedMobileNumber + mobile.dropFirst(maskedMobileNumber.count)
}

public func mask(email: String) -> String {
    var maskedEmail: String = ""
    var emailContainer: String = ""
    for i in email {
        emailContainer += "*"
        guard !(i == "@") else { break }
    }
    maskedEmail = String(email.prefix(1) + "\(emailContainer.dropFirst(2))" + email.dropFirst(emailContainer.count - 1))
    return maskedEmail
}

public func mask(username: String) -> String {
    if ValidationService.shared.validateEmail(username) { return mask(email: username) } else { return mask(mobile: username) }
}

public func formattedCardNumber(cardNumber: String) -> String {
    let stride: Int = 4
    let separator: Character = " "
    return String(cardNumber.enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
}
