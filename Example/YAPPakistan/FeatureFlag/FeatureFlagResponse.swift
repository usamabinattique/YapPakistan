//
//  FeatureFlagResponse.swift
//  YAPPakistan_Example
//
//  Created by Umer on 23/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

struct FeatureFlagResponse: Decodable {
    let features: [FeatureFlag]
    private enum CodingKeys: String, CodingKey  {
        case features
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        features = try values.decode([FeatureFlag].self, forKey: .features)
    }
}
