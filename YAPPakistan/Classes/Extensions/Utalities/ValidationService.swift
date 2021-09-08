//
//  ValidationService.swift
//  YAP
//
//  Created by MHS on 05/07/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation
import RxSwift


public class ValidationService {
    public static let shared = ValidationService()
    
   public func validateEmail(_ email: String?) -> Bool {
        guard  let email = email else { return false }
    let regex = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9]{2,61}(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if predicate.evaluate(with: email) == true {
            return true
        } else {
            return false
        }
    }
    
    public func validateName(_ name: String?, maxLength: Int = 50) -> Bool {
        guard  let `name` = name else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count > 1 else { return false }
        let nameRegEx = "^[a-zA-Z]{1}[a-zA-Z ]{1,\(maxLength)}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    public func validateLastName(_ name: String?) -> Bool {
        guard  let `name` = name else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count > 0 else { return false }
        let nameRegEx = "^[a-zA-Z ]{1,100}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    public func validateBankInfo(_ info: String?, _ maxLength: Int = 35) -> Bool {
        guard  let `info` = info else { return false }
        let trimmedInfo = info.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedInfo.count > 1 else { return false }
        let infoRegEx = "^[a-zA-Z ]{2,\(maxLength)}$"
        let infoTest = NSPredicate(format: "SELF MATCHES %@", infoRegEx)
        return infoTest.evaluate(with: info)
    }
    
    public func validatePasscode(_ passcode: String?) throws {
        guard let `passcode` = passcode else { return }
        
        let passcodeDigits = passcode.map { Int(String($0)) ?? 0 }
        
        var sequence = true
        var similar = true
        
        for i in 0..<passcodeDigits.count-1 {
            if passcodeDigits[i+1] - passcodeDigits[i] != 1 { sequence = false }
            if passcodeDigits[i] != passcodeDigits[i+1] { similar = false }
        }
        
        if sequence { throw ValidationError.passcodeSequence }
        if similar { throw ValidationError.passcodeSameDigits }
    }
    
    public func validatePIN(_ pin: String?) throws {
       
        guard let `pin` = pin else { return }
        
        if pin.isEmpty { throw ValidationError.invalid("Empty field") }
        
        let pinDigits = pin.map { Int(String($0)) ?? 0 }
        
        if pinDigits.count != 4  { throw ValidationError.invalid("Empty field") }
        
        
        var sequence = true
        var similar = true
        
        for i in 0..<pinDigits.count-1 {
            if pinDigits[i+1] - pinDigits[i] != 1 { sequence = false }
            if pinDigits[i] != pinDigits[i+1] { similar = false }
        }
        
        if sequence { throw ValidationError.passcodeSequence }
        if similar { throw ValidationError.passcodeSameDigits }
    }
    
    public func validateIBAN(_ IBAN: String, for countryCode: String) -> Bool {
        let ibanRegex = "^\(countryCode)[0-9]{2}[0-9A-Z]{1,31}$"
        let ibanTest = NSPredicate(format: "SELF MATCHES %@", ibanRegex)
        return ibanTest.evaluate(with: IBAN)
    }
    
    public func validateAccountNumber(_ accountNumber: String) -> Bool {
        let accountNumberRegex = "^[0-9]{4,34}$"
        let accountNumberTest = NSPredicate(format: "SELF MATCHES %@", accountNumberRegex)
        return accountNumberTest.evaluate(with: accountNumber)
    }
    
    public func validateSWIFT(_ SWIFT: String) -> Bool {
        let swiftRegex = "^[0-9A-Z]{4,11}$"
        let swiftTest = NSPredicate(format: "SELF MATCHES %@", swiftRegex)
        return swiftTest.evaluate(with: SWIFT)
    }
    
    public func validateCity(_ name: String?) -> Bool {
        guard  let `name` = name else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count > 1 else { return false }
        let nameRegEx = "^[a-zA-Z]{1}[a-zA-Z ]{1,50}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    public func validateTransactionRemarks(_ remarks: String?) -> Bool {
        guard let `remarks` = remarks, !remarks.isEmpty else { return true }
        let remarksRegEx = "^[a-zA-Z0-9]{1}[a-zA-Z0-9 ]{0,29}$"
        let remarksTest = NSPredicate(format: "SELF MATCHES %@", remarksRegEx)
        return remarksTest.evaluate(with: remarks)
    }
}

// MARK: Validation errors

public enum ValidationError: LocalizedError {
    case passcodeSameDigits
    case passcodeSequence
    case invalid(String)
}

extension ValidationError {
    public var errorDescription: String? {
        switch self {
        case .passcodeSequence:
            return  "screen_create_passcode_display_text_error_sequence".localized
        case .passcodeSameDigits:
            return  "screen_create_passcode_display_text_error_same_digits".localized
        case .invalid(let error):
            return error
        }
    }
}
