//
//  String+Extensions.swift
//  YAPKit
//
//  Created by Zain on 25/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import PhoneNumberKit

extension String {
    var doubleValue: Double {
        let number = localeNumberFormatter.number(from: self) ?? 0
        return Double(exactly: number) ?? 0
    }
}

extension String {
//    func initialsImage(color: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
//        return initialsImage(backgroundColor: color.withAlphaComponent(0.15), textColor: color, size: size)
//    }
    
//    func initialsImage(backgroundColor: UIColor, textColor: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
//        let nameLabel = UILabel()
//        nameLabel.frame.size = size
//        nameLabel.textColor = textColor
//
//        let comps = components(separatedBy: .whitespaces).filter({ !$0.isEmpty })
//        nameLabel.text = comps.count > 1 ? [comps.first?.first?.uppercased(), comps.last?.first?.uppercased()].compactMap({ $0 }).joined() : comps.first?.first?.uppercased()
//        nameLabel.font = UIFont.appFont(ofSize: 32 * (size.height/100), weigth: .semibold, theme: .main)
//        nameLabel.textAlignment = NSTextAlignment.center
//        nameLabel.backgroundColor = backgroundColor
//
//        UIGraphicsBeginImageContext(nameLabel.frame.size)
//        nameLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        guard let data = newImage?.jpegData(compressionQuality: 1.0) else { return newImage! }
//
//        return UIImage.init(data: data)!
//    }

}

extension String {
    func removingGroupingSeparator() -> String {
        return self.replace(string: localeNumberFormatter.currencyGroupingSeparator, replacement: "")
    }
    
    func replacingDecimalSeparator() -> String {
        return self.replace(string: ".", replacement: localeNumberFormatter.currencyDecimalSeparator)
    }
}
