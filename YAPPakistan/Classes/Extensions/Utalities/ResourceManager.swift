//
//  ResourceManager.swift
//  YAPKit
//
//  Created by Zain on 19/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public class ResourceManager {

    public class var appCountries: [AppCountry]? {
        guard let url = Bundle.yapPakistan.url(forResource: "Countries", withExtension: "json"),
            let jsonString = try? String(contentsOf: url),
            let jsonData = jsonString.data(using: .utf8),
            let countries = try? JSONDecoder().decode([AppCountry].self, from: jsonData)
        else { return nil }
        return countries
    }
}

var ibanValidationRegexes: [String: String] {
    if let path = Bundle.yapPakistan.path(forResource: "IBANRegex", ofType: "plist") {
        let dictRoot = NSDictionary(contentsOfFile: path)

        if let dict = dictRoot as? [String: String] {
            return dict
        }
    }
    return [:]
}

public func appShareMessageForY2Y(welcomeMessage message: String, appShareUrl: String) -> String {
    return String(format: "common_display_text_y2y_share".localized, message, appShareUrl)
}

public func appShareMessageForMore( _ downloadURL: String) -> String {
    return String(format: "screen_invite_friend_display_text_share_url".localized, downloadURL)
}

public func appInviteWaitingList( _ downloadURL: String) -> String {
    return String(format: "screen_waiting_list_rank_share_invite_text".localized, downloadURL)
}

public func appShareMessageForCardsPlan( _ downloadURL: String) -> String {
    return String(format: "screen_invite_friend_cards_&_plan_display_text_share_url".localized, downloadURL)
}
