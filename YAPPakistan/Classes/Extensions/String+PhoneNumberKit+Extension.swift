//
//  String+PhoneNumberKit+Extension.swift
//  YAPPakistan
//
//  Created by Sarmad on 23/09/2021.
//

import Foundation
import PhoneNumberKit

extension String {
    var toSimplePhoneNumber:String {
        return self.replacingOccurrences(of: "+", with: "00").replacingOccurrences(of: " ", with: "")
    }

    var toFormatedPhoneNumber:String {
        guard self.count > 2 else { return self }

        let phoneNumberKit = PhoneNumberKit()
        if let pNumber = try? phoneNumberKit.parse(self) {
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return formattedNumber
        }

        return self
    }
}
