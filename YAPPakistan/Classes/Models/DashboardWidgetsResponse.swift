//
//  DashboardWidgetsResponse.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation

// MARK: - WidgetsData
public struct DashboardWidgetsResponse : Codable {
    public let id : Int?
    public let name : String?
    public let icon : String?
    public var status : Bool?
    public var shuffleIndex : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case icon = "icon"
        case status = "status"
        case shuffleIndex = "shuffleIndex"
    }
    
    public var iconPlaceholder: UIImage?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        shuffleIndex = try values.decodeIfPresent(Int.self, forKey: .shuffleIndex)
    }
    
    public init(id: Int?, name: String?, icon: String?, status: Bool?, shuffleIndex: Int?) {
        self.id = id
        self.name = name
        self.icon = icon
        self.status = status
        self.shuffleIndex = shuffleIndex
    }

}

public struct UpdateDashboardWidgetsResponse : Codable {
    public let errors : [Failed]?
    public let data : String?

    enum CodingKeys: String, CodingKey {

        case errors = "errors"
        case data = "data"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        errors = try values.decodeIfPresent([Failed].self, forKey: .errors)
        data = try values.decodeIfPresent(String.self, forKey: .data)
    }
}

public struct Failed : Codable {
    public let code : String?
    public let message : String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }
}


public extension DashboardWidgetsResponse {
    static var mock: DashboardWidgetsResponse {
        return DashboardWidgetsResponse(id: 0, name: "Send money", icon: nil, status: true, shuffleIndex: 0)
    }
}
