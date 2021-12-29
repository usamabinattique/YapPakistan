//
//  CardDesign.swift
//  Cards
//
//  Created by Zain on 18/12/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit

struct CardDesign {
    let designCodeName: String
    let designCode: String
    let frontImageUrl: String?
    let backImageUrl: String?
    let isActive: Bool
    let colorCodes: [CardDesignColorCode]
}

extension CardDesign: Codable {
    enum CodingKeys: String, CodingKey {
        case designCodeName = "designCodeName"
        case designCode = "designCode"
        case frontImageUrl = "frontSideDesignImage"
        case backImageUrl = "backSideDesignImage"
        case isActive = "status"
        case colorCodes = "designCodeColors"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CardDesign.CodingKeys.self)
        designCodeName = (try? container.decode(String?.self, forKey: .designCodeName)) ?? ""
        designCode = (try? container.decode(String?.self, forKey: .designCode)) ?? ""
        frontImageUrl = try? container.decode(String?.self, forKey: .frontImageUrl)
        backImageUrl = try? container.decode(String?.self, forKey: .backImageUrl)
        isActive = ((try? container.decode(String?.self, forKey: .designCode)) ?? "") == "ACTIVE"
        colorCodes = (try? container.decode([CardDesignColorCode]?.self, forKey: .colorCodes)) ?? []
    }
}


struct CardDesignColorCode {
    let colorCode: String
    let colorCodeId: String
}

extension CardDesignColorCode: Codable {
    enum CodingKeys: String, CodingKey {
        case colorCode = "colorCode"
        case colorCodeId = "designCodeUUID"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CardDesignColorCode.CodingKeys.self)
        colorCode = (try? container.decode(String?.self, forKey: .colorCode)) ?? ""
        colorCodeId = (try? container.decode(String?.self, forKey: .colorCodeId)) ?? ""
    }
}

extension CardDesign {
    var gradiants: [UIColor] {
        var gradiants = colorCodes.map({ $0.color })
        if gradiants.count < 2 {
            let first: UIColor = gradiants.first ?? .gray //.greyLight
            gradiants.removeAll()
            gradiants.append(contentsOf: [first, first])
        }
        return Array(gradiants.prefix(2))
    }
}

extension CardDesignColorCode {
    var color: UIColor { UIColor(Color(hex: colorCode)) } // UIColor(hexString: colorCode)
}

//extension CardDesign {
//    static var mock: CardDesign {
//        CardDesign(designCodeName: "DC1", designCode: "DC1", frontImageUrl: YAPCard.virtualDarkBlue.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//            CardDesignColorCode(colorCode: "#443d92", colorCodeId: ""),
//            CardDesignColorCode(colorCode: "#272262", colorCodeId: "")
//        ])
//    }
//
//    static var mockData: [CardDesign] {
//        [
//            CardDesign(designCodeName: "DC1", designCode: "DC1", frontImageUrl: YAPCard.virtualDarkBlue.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//                CardDesignColorCode(colorCode: "#443d92", colorCodeId: ""),
//                CardDesignColorCode(colorCode: "#272262", colorCodeId: "")
//            ]),
//            CardDesign(designCodeName: "DC2", designCode: "DC2", frontImageUrl: YAPCard.virtualGreen.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//                CardDesignColorCode(colorCode: "#44d7b6", colorCodeId: ""),
//                CardDesignColorCode(colorCode: "#cbe1e7", colorCodeId: "")
//            ]),
//            CardDesign(designCodeName: "DC2", designCode: "DC2", frontImageUrl: YAPCard.virtualMulti.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//                CardDesignColorCode(colorCode: "#88c8f9", colorCodeId: ""),
//                CardDesignColorCode(colorCode: "#8b489c", colorCodeId: "")
//            ]),
//            CardDesign(designCodeName: "DC2", designCode: "DC2", frontImageUrl: YAPCard.virtualLightBlue.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//                CardDesignColorCode(colorCode: "#48b3d3", colorCodeId: "")
//            ]),
//            CardDesign(designCodeName: "DC2", designCode: "DC2", frontImageUrl: YAPCard.virtualPurple.cardImageUrl, backImageUrl: nil, isActive: true, colorCodes: [
//                CardDesignColorCode(colorCode: "#a582ff", colorCodeId: "")
//            ])
//        ]
//    }
//}
