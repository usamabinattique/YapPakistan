//
//  String+Extensions.swift
//  YAPKit
//
//  Created by Zain on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import PhoneNumberKit

public extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }

    var initials: String {

        let words = components(separatedBy: .whitespacesAndNewlines)

        // to identify letters
        let letters = CharacterSet.letters
        var firstChar: String = ""
        var secondChar: String = ""
        var firstCharFoundIndex: Int = -1
        var firstCharFound: Bool = false
        var secondCharFound: Bool = false

        for (index, item) in words.enumerated() {

            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            // browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                // check if its a aplha
                if letters.contains(char) {

                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index

                    } else if !secondCharFound {

                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        break
                    } else {
                        break
                    }
                }
            }
        }
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "Y"
            secondChar = "P"
        }

        return firstChar + secondChar
    }

    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) == nil
    }

    var isPhoneNumberType: Bool {
        return !isEmpty && range(of: "[^0-9+]", options: .regularExpression) == nil
    }

    var isEmailType: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9.@]", options: .regularExpression) == nil
    }

    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var isHexString: Bool {
        let hexCharSet = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return uppercased().rangeOfCharacter(from: hexCharSet) == nil
    }

    /// var doubleValue: Double {
    ///    let number = localeNumberFormatter.number(from: self) ?? 0
    ////        return Double(exactly: number) ?? 0
    ////    }

    var serverReadableDateFormate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        let showDate = inputFormatter.date(from: self)
        inputFormatter.dateFormat = "yyyy-MM-dd"
        return inputFormatter.string(from: showDate!)
    }

}

public extension String {
    var splitCodeAndNumber: (String, String) {
        let formattedPhoneNumber = String.format(phoneNumber: self)
        var countryCode: String?
        var number: String?
        var components = formattedPhoneNumber.components(separatedBy: " ")
        countryCode = components.first?.replacingOccurrences(of: "+", with: "00")
        components.removeFirst()
        number = components.joined()
        return (countryCode ?? "invalid code", number ?? "invalid number")
    }

    static func format(phoneNumber phone: String) -> String {
        do {
            let phoneNumberKit = PhoneNumberKit()
            let number = try phoneNumberKit.parse(phone)
            let formattedNumber = phoneNumberKit.format(number, toType: .international)
            return formattedNumber
        } catch {
            print(error)
        }
        return phone
    }

    func initialsImage(color: UIColor, font: UIFont? = nil, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        return initialsImage(backgroundColor: color.withAlphaComponent(0.15), font: font, textColor: color, size: size)
    }

    func initialsImage(backgroundColor: UIColor, font: UIFont? = nil, textColor: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let nameLabel = UILabel()
        nameLabel.frame.size = size
        nameLabel.textColor = textColor

        let comps = components(separatedBy: .whitespaces).filter({ !$0.isEmpty })
        nameLabel.text = comps.count > 1 ? [comps.first?.first?.uppercased(), comps.last?.first?.uppercased()].compactMap({ $0 }).joined() : comps.first?.first?.uppercased()
        nameLabel.font = UIFont.systemFont(ofSize: 32 * (size.height/100), weight: .semibold) // theme: .main
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.backgroundColor = backgroundColor

        UIGraphicsBeginImageContext(nameLabel.frame.size)
        nameLabel.layer.render(in: UIGraphicsGetCurrentContext()!)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let data = newImage?.jpegData(compressionQuality: 1.0) else { return newImage! }

        return UIImage(data: data)!
    }
    
    private func thumbnail(name: String) -> UIImage? {
        let color = UIColor.randomColor()
        return name.initialsImage(color: color)
       // return thumbnailData != nil ? UIImage.init(data: thumbnailData!) : name.initialsImage(color: color)
    }
    
    var thumbnail : UIImage? {
        let color = UIColor.randomColor()
        return self.initialsImage(color: color)
    }
}

public extension String {
    func subString(_ from: Int, length to: Int) -> String {
        if count == 0 {
            return ""
        }
        let f: String.Index = index(startIndex, offsetBy: from < count ? from : count - 1)
        let t: String.Index = index(startIndex, offsetBy: to <= count ? to : count)
        return String(self[f..<t])
    }

    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: String.CompareOptions.literal, range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }

    func removePlus() -> String {
        return self.replace(string: "+", replacement: "").removeWhitespace()
    }

    /*func removingGroupingSeparator() -> String {
        return self.replace(string: localeNumberFormatter.currencyGroupingSeparator, replacement: "")
    }
    
    func replacingDecimalSeparator() -> String {
        return self.replace(string: ".", replacement: localeNumberFormatter.currencyDecimalSeparator)
    } */

    var formattedDateString: String {
        guard self.count != 19 else { return self }

        if self.count > 19 {
            return self.subString(0, length: 19)
        }

        if self.count == 16 {
            return self + ":00"
        }

        return self

    }
}

public extension NSAttributedString.Key {
    static let clickableLink: NSAttributedString.Key = NSAttributedString.Key(rawValue: "clickableLink")
}

// MARK: - String Localizable

public extension String {
    func firstCharacterUpperCase() -> String? {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
}

public extension String {
    static var empty: Self { return "" }
}

extension String {
    func replacePrefix(_ prefix: String,with ext: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        let refinedString = String(self.dropFirst(prefix.count))
        return ext+refinedString
    }
}

public extension String {
    var firstAndLastLetters: String {
        let fullNameArr = self.components(separatedBy: " ")
        let firstLetter = fullNameArr.first ?? ""
        let lastLetter = fullNameArr.last ?? ""
        return "\(firstLetter) \(lastLetter)"
    }
    
    var firstCharacterAndLastLetter: String {
        let fullNameArr = self.components(separatedBy: " ")
        let firstCharacter = String(Array(self)[0]) 
        let lastLetter = fullNameArr.last ?? "" //Last
        return "\(firstCharacter) \(lastLetter)"
    }
    
    var firstLetter: String {
        let fullNameArr = self.components(separatedBy: " ")
        return fullNameArr.first ?? ""
    }
    
    // number of spaces
    var splits: Int {
        return self.components(separatedBy: " ").count - 1
    }
    
    var length: Int {
        return self.count
    }
    
    var allLettersSepartedBySpaces: [String] {
        return self.components(separatedBy: " ")
    }
}
