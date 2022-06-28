//
//  SocialMedia.swift
//  YAPPakistan
//
//  Created by Yasir on 28/06/2022.
//

import Foundation
import YAPComponents

public enum SocialMediaType: String {
    case facebook = "Facebook"
    case linkedin = "LinkedIn"
    case tiktok = "TikTok"
    case youtube = "YouTube"
    case twitter = "Twitter"
    case none = ""
}

//public struct SocialMedia: Codable {
//    let platformName: String
//    let browserLink: String
//    let appLink: String
//
//   // let platformType: SocialMediaType?
//}

public struct SocialMedia: Codable {
    let platformName: String?
    let browserLink: String?
    let appLink: String?

    enum CodingKeys: String, CodingKey {

        case platformName
        case browserLink
        case appLink
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        platformName = try values.decodeIfPresent(String.self, forKey: .platformName)
        browserLink = try values.decodeIfPresent(String.self, forKey: .browserLink)
        appLink = try values.decodeIfPresent(String.self, forKey: .appLink)
    }

}


/*
extension SocialMedia: Codable {
    
    enum CodingKeys: String, CodingKey {
        case platformName
        case browserLink
        case appLink
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SocialMedia.CodingKeys.self)
        
        platformName = ((try? container.decodeIfPresent(String?.self, forKey: .platformName)) ?? "") ?? ""
        //platformName = SocialMediaType(rawValue: platformNameString ?? "") ?? .facebook
        browserLink = (try? container.decodeIfPresent(String?.self, forKey: .browserLink) ?? "") ?? ""
        appLink = (try? container.decodeIfPresent(String?.self, forKey: .appLink) ?? "") ?? ""
       // platformType = SocialMediaType(rawValue: platformName)
    }
} */
/*
public extension SocialMedia {
    var platformType: SocialMediaType {
        switch platformName {
        case "Facebook":
            return .facebook
        case "LinkedIn":
            return .linkedin
        case "TikTok":
            return .tiktok
        case "YouTube":
            return .youtube
        }
    }
} */

//extension SocialMedia {
//    static var mock: SocialMedia {
//        return SocialMedia(platformName: "Facebook", browserLink: "", appLink: "")
//    }
//}
