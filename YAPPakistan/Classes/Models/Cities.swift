//
//  Cities.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/10/2021.
//

import Foundation

public struct Cities: Codable {
    let creationDate: String?
    let createdBy: String?
    let updatedDate: String?
    let updatedBy: String?
    let name: String?
    let cityCode: String?
    let active: Bool?
    let iata3Code: String?
    let updatedOn: String?

    enum CodingKeys: String, CodingKey {

        case creationDate
        case createdBy
        case updatedDate
        case updatedBy
        case name
        case cityCode
        case active
        case iata3Code
        case updatedOn
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        creationDate = try values.decodeIfPresent(String.self, forKey: .creationDate)
        createdBy = try values.decodeIfPresent(String.self, forKey: .createdBy)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        updatedBy = try values.decodeIfPresent(String.self, forKey: .updatedBy)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        cityCode = try values.decodeIfPresent(String.self, forKey: .cityCode)
        active = try values.decodeIfPresent(Bool.self, forKey: .active)
        iata3Code = try values.decodeIfPresent(String.self, forKey: .iata3Code)
        updatedOn = try values.decodeIfPresent(String.self, forKey: .updatedOn)
    }

}
