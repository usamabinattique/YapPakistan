//
//  ProfilePhotoResponse.swift
//  Networking
//
//  Created by Muhammad Hassan on 07/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct ProfilePhotoResponse: Codable {
    public let imageUrl: URL

    enum CodingKeys: String, CodingKey {
        case imageUrl = "imageURL"
    }
}
