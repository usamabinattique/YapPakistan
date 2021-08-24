//
//  Response.swift
//  Networking
//
//  Created by Muhammad Hassan on 28/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

struct Response<T: Codable>: Codable {
    let result: T
    let serverErrors: [ServerError]?
}

extension Response {
    private enum CodingKeys: String, CodingKey {
        case result = "data"
        case serverErrors = "errors"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decode(T.self, forKey: .result)
        serverErrors = try values.decode([ServerError]?.self, forKey: .serverErrors)
    }
}
