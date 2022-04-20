//
//  DashboardWidgetsRequest.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation

public struct DashboardWidgetsRequest: Codable {
    
    public let id : Int
    public let status : Bool
    public let shuffleIndex : Int
    
    public init(id: Int, status: Bool, shuffleIndex: Int) {
        self.id = id
        self.status = status
        self.shuffleIndex = shuffleIndex
    }
    
}
