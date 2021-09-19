//
//  PagableResponse.swift
//  Networking
//
//  Created by Wajahat Hassan on 21/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct PagableResponse<T: Codable>: Codable {
    public let content: [T]?
    public let totalPages: Int
    public let totalElements: Int
    public let isLast: Bool
    public let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case content, totalPages, totalElements
        case isLast = "last"
        case currentPage = "number"
    }
}

extension PagableResponse: Equatable {
    public static func == (lhs: PagableResponse<T>, rhs: PagableResponse<T>) -> Bool {
        return lhs.currentPage == rhs.currentPage &&
        lhs.totalElements == rhs.totalElements &&
        lhs.totalPages == rhs.totalPages
    }
}

public extension PagableResponse {
    init(content: [T], totalPages: Int, totalElements: Int, isLast: Bool, currentPage: Int) {
        self.content = content
        self.totalPages = totalPages
        self.totalElements = totalElements
        self.isLast = isLast
        self.currentPage = currentPage
    }
}
