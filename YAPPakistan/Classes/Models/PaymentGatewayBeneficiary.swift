//
//  PaymentGatewayBeneficiary.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import Foundation

enum ExternalPaymentCardType: String, Codable {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case americanExpress = "American Express"
    case dinersClub = "Diners Club"
    case jcb = "JCB"
    case disocver = "Discover"
    case other = "Other"
}

extension ExternalPaymentCardType {
    var scheme: String? {
        switch self {
        case .visa:
            return "Visa"
        case .mastercard:
            return "Mastercard"
        case .americanExpress:
            return "American Express"
        case .dinersClub:
            return "Diners Club"
        case .jcb:
            return "JCB"
        case .disocver:
            return "Discover"
        case .other:
            return nil
        }
    }
    //TODO: add missing images in assets
    var logoImage: UIImage? {
        
        switch self {
        case .visa:
            return UIImage.init(named: "logo_visa", in: .yapPakistan, compatibleWith: nil)
        case .mastercard:
            return UIImage.init(named: "logo_master_card", in: .yapPakistan, compatibleWith: nil)
        case .americanExpress:
            return UIImage.init(named: "logo_american_express", in: .yapPakistan, compatibleWith: nil)
        case .dinersClub:
            return UIImage.init(named: "logo_diners_club", in: .yapPakistan, compatibleWith: nil)
        case .jcb:
            return UIImage.init(named: "logo_jcb", in: .yapPakistan, compatibleWith: nil)
        case .disocver:
            return UIImage.init(named: "logo_discover", in: .yapPakistan, compatibleWith: nil)
        case .other:
            return nil
        }
    }
}

/**
Representation of external card to be used for top up.
*/
public struct ExternalPaymentCard: Codable {
    let id: Int
    let name: String
    let expiry: String
    let last4Digits: String
    let nickName: String
    let color: String?
    
    var type: ExternalPaymentCardType {
        return ExternalPaymentCardType(rawValue: name) ?? .mastercard
    }
}

extension ExternalPaymentCard {
    private enum CodingKeys: String, CodingKey {
        case id, expiry, color
        case name = "logo"
        case last4Digits = "number"
        case nickName = "alias"
    }
}

extension ExternalPaymentCard {
    var maskedNumber: String {
        return "XXXX XXXX XXXX \(last4Digits)"
    }
    
    var expiryDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMyy"
        return dateFormatter.date(from: expiry)
    }
    
    var cardDate: String {
        let brokenDate = "\(expiry.subString(0, length: 2))/20\(expiry.subString(2, length: 2))"
        guard let expiry = expiryDate else {
            return brokenDate
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        return dateFormatter.string(from: expiry)
    }
    
    func cardImage(withWidth width: CGFloat = 300) -> UIImage? {
        return cardImage(withHeight: width / 1.586)
    }
    
    func cardImage(withHeight _height: CGFloat) -> UIImage? {
        
        let height = _height * UIScreen.main.scale
        let width = 1.586 * height
        
        let bgColor = ((color?.isHexString ?? false) ? UIColor(hexString: color!) :  UIColor(Color(hex: "#5E35B1")) ) ?? .white //primary
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
       
        
        let gradiant = CAGradientLayer()
        gradiant.frame = view.bounds
        
        gradiant.colors = [(bgColor.lighten(by: 10)).cgColor, (bgColor.darken(by: 10)).cgColor]
        view.layer.addSublayer(gradiant)
        
        view.layer.cornerRadius = 0.055 * width
        view.clipsToBounds = true
        
        let chip = UIImageView(frame: CGRect(x: 0.077 * width, y: 0.136 * height, width: 0.135 * width, height: 0.1358 * width))
        chip.contentMode = .scaleAspectFit
        chip.image = UIImage.init(named: "icon_card_chip", in: .yapPakistan)
        view.addSubview(chip)
        
        let nameLabel = UILabel(frame: CGRect(x: 0.253*width, y: 0.179*height, width: 0.747*width, height: 0.129*height))
        nameLabel.font = .systemFont(ofSize: 0.054 * width)
        nameLabel.textColor = .white
        nameLabel.text = nickName
        view.addSubview(nameLabel)
        
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 0.501*height, width: width, height: 0.172*height))
        numberLabel.font = .systemFont(ofSize: 0.072 * width)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.text = maskedNumber
        view.addSubview(numberLabel)
        
        let dateLabel = UILabel(frame: CGRect(x: width/2, y: 0.788 * height, width: width*0.45, height: 0.129*height))
        dateLabel.font = .systemFont(ofSize: 0.054 * width)
        dateLabel.textColor = .white
        dateLabel.textAlignment = .right
        dateLabel.text = cardDate
        view.addSubview(dateLabel)
        
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0.17 * width, height: 0.17 * width))
        logo.center = CGPoint(x: chip.center.x, y: dateLabel.center.y)
        logo.contentMode = .scaleAspectFit
        logo.image = self.type.logoImage
        view.addSubview(logo)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(view.frame.size)
        UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).addClip()
        newImage?.draw(in: view.bounds)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
}
