//
//  AppReferralManager.swift
//  AppAnalytics
//
//  Created by Zain on 02/03/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import Adjust

public class AppReferralManager {
    private static let inviterIdKey = "REFERRAL_INVITER_ID"
    private static let invitationTimeKey = "REFERRAL_INVITATION_TIME"

    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func getReferralUrl(for inviterId: String, time: Date = Date()) -> String {
        switch environment {
        case .dev:
            return "https://grwl.adj.st?adjust_t=q3o2z0e_sv94i35&customer_id=\(inviterId)&time=\(refferalTimeString())"
        case .qa:
            return "https://grwl.adj.st?adjust_t=q3o2z0e_sv94i35&customer_id=\(inviterId)&time=\(refferalTimeString())"
        case .stg:
            return "https://grwl.adj.st?adjust_t=q3o2z0e_sv94i35&customer_id=\(inviterId)&time=\(refferalTimeString())"
        case .preprod:
            return "https://7s29.adj.st?adjust_t=v3jlxlh_oo71763&customer_id=\(inviterId)&time=\(refferalTimeString())"
        case .prod:
            return "https://gqvg.adj.st?adjust_t=n44w5ee_6hpplis&customer_id=\(inviterId)&time=\(refferalTimeString())"
        }
    }
    
    func refferalTimeString() -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: Date())
    }
    
    func saveReferralInformation(inviterId: String, time: String) {
        UserDefaults.standard.set(inviterId, forKey: Self.inviterIdKey)
        UserDefaults.standard.set(time, forKey: Self.invitationTimeKey)
    }
    
    func removeReferralInformation() {
        UserDefaults.standard.removeObject(forKey: Self.inviterIdKey)
        UserDefaults.standard.removeObject(forKey: Self.invitationTimeKey)
    }
    
    func parseReferralUrl(_ url: URL?) {
        guard let `url` = url else { return }
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        let inviterId = urlComponents.queryItems?.filter{ $0.name == "customer_id" }.first?.value
        let time = urlComponents.queryItems?.filter{ $0.name == "time" }.first?.value
        
        guard let inviter = inviterId, let invitationTime = time else { return }
        
        saveReferralInformation(inviterId: inviter, time: invitationTime)
    }
    
    var isReferralInformationAvailable: Bool {
        guard (UserDefaults.standard.object(forKey: Self.inviterIdKey) as? String) != nil,
              (UserDefaults.standard.object(forKey: Self.invitationTimeKey) as? String) != nil else {
            return false
        }

        return true
    }
    
    var inviterId: String? {
        UserDefaults.standard.object(forKey: Self.inviterIdKey) as? String
    }
    
    var invitationTime: Date? {
        guard let timeString = UserDefaults.standard.object(forKey: Self.invitationTimeKey) as? String,
              let timeInterval = Double(timeString) else {
            return nil
        }

        return Date(timeIntervalSince1970: timeInterval)
    }
    
    var invitationTimeString: String? {
        return UserDefaults.standard.object(forKey: Self.invitationTimeKey) as? String
    }
}
