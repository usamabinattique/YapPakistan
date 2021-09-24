//
//  FeatureFlag.swift
//  YAPPakistan_Example
//
//  Created by Umer on 21/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

struct FeatureFlag {
    let key: String
    let title: String
    let description: String
    let value: Bool
    let subFeatures: [FeatureFlag]?
}

extension FeatureFlag: Codable {
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case value
        case subFeatures
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        value = try values.decode(Bool.self, forKey: .value)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        subFeatures = try? values.decodeIfPresent([FeatureFlag].self, forKey: .subFeatures)
    }
}
