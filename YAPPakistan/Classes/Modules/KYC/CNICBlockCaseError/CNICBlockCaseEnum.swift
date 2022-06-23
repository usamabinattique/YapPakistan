//
//  CNICBlockCaseEnum.swift
//  YAPPakistan
//
//  Created by Awais on 23/06/2022.
//

import Foundation

public enum CNICBlockCase  {
    
    case underAge
    case cnicAlreadyUsed
    case invalidCNIC
    case cnicExpiredOnScane
    
    var errorCode: String {
        switch self {
        case .cnicAlreadyUsed:
            return "10400"
        case .cnicExpiredOnScane:
            return "10640"
        case .invalidCNIC:
            return "10404"
        case .underAge:
            return "10018"
        }
    }
    
    var errorTitle : String {
        switch self {
        case .invalidCNIC:
            return "Oops, looks like that CNIC doesn’t exist!"
        case .cnicExpiredOnScane:
            return "Looks like your CNIC is expired!"
        case .cnicAlreadyUsed:
            return "Oops! You’re CNIC is linked to another account!"
        case .underAge:
            return "Looks like you’re under 18!"
        }
    }
    
    var errorDescription : String {
        switch self {
        case .underAge:
            return "Unfortunately, YAP is only available to users over the age of 18. But don’t worry! We’re working on bringing something special to our younger audiences soon 😉 "
        case .cnicAlreadyUsed:
            return "Your CNIC is already linked to another account! Please log out and try logging into that account. If you forgot your details, please reach out to our customer service team for help."
        case .invalidCNIC:
            return "To complete your YAP account, please re-scan with a valid CNIC and try again. "
        case .cnicExpiredOnScane:
            return "To complete your YAP account. please re-scan with a valid CNIC and try again. "
        }
    }
}
