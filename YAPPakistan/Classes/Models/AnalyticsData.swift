//
//  AnalyticsCategory.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import UIKit

public enum CategoryType: String, CaseIterable {
    case travel = "travel"
    case utilities = "utilities"
    case shopping = "shopping"
    case groceries = "groceries"
    case mediaAndEntertainment = "media and entertainment"
    case foodAndDrinks = "food and drinks"
    case services = "services"
    case transport = "transport"
    case healthAndBeauty = "health and beauty"
    case insurance = "insurance"
    case education = "education"
    case airportLounge = "airport lounge"
    case other = "other"
}

extension CategoryType {
    var icon: UIImage? {
        switch self {
        case .travel:
            return UIImage.init(named: "icon_category_travel", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .utilities:
            return UIImage.init(named: "icon_category_utilities", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .shopping:
            return UIImage.init(named: "icon_category_shopping", in: .yapPakistan, compatibleWith: nil)?.asTemplate
//        case .groceries:
//            return UIImage.init(named: "icon_category_groceries", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .groceries:
            return UIImage.init(named: "", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .mediaAndEntertainment:
            return UIImage.init(named: "icon_category_entertainment", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .foodAndDrinks:
            return UIImage.init(named: "icon_category_food", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .services:
            return UIImage.init(named: "icon_category_services", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .transport:
            return UIImage.init(named: "icon_category_transport", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .healthAndBeauty:
            return UIImage.init(named: "icon_category_health", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .insurance:
            return UIImage.init(named: "icon_category_insurance", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .education:
            return UIImage.init(named: "icon_category_education", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .airportLounge:
            return UIImage.init(named: "icon_category_ariport", in: .yapPakistan, compatibleWith: nil)?.asTemplate
//        case .other:
//            return UIImage.init(named: "icon_category_other", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        case .other:
            return UIImage.init(named: "", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        }
    }
    public var toString: String {
          get {
              return rawValue.prefix(1).uppercased() + rawValue.dropFirst().lowercased()
          }
      }
}

enum AnalyticsDataType {
    case category
    case merchant
}

struct AnalyticsData: Codable {
    let transactions: Int
    let spending: Double
    let percentage: Double
    private let _title: String?
    let logoUrl: String?
    var title: String { _title?.capitalized ?? "Other"}
    var categories: [String]?
    var categoryId: Int?
    var categoryColor: String?
    
    enum CodingKeys: String, CodingKey {
        case transactions = "txnCount"
        case spending = "totalSpending"
        case percentage = "totalSpendingInPercentage"
        case _title = "title"
        case logoUrl = "logoUrl"
        case categories = "categories"
        case categoryId = "yapCategoryId"
        case categoryColor = "categoryColor"
    }
}

extension AnalyticsData {
    static var empty: AnalyticsData {
        return AnalyticsData(transactions: 0, spending: 0, percentage: 0, _title: "", logoUrl: nil)
    }
    
    static var mocked: AnalyticsData {
        return AnalyticsData(transactions: 10, spending: 3423.2, percentage: 20.0, _title: "Travel", logoUrl: nil)
    }
    
    func icon(type: AnalyticsDataType, color: UIColor) -> UIImage? {
        type == .category ? CategoryType(rawValue: title.lowercased().replacingOccurrences(of: "&", with: "and"))?.icon ?? CategoryType.other.icon : title.initialsImage(color: color, font: .regular)
    }
}

struct Analytics: Codable {
    let numberOfTransactions: Int
    let totalAmount: Double
    let date: Date
    let analytics: [AnalyticsData]
    let monthlyAverage: Double
    
    var type: AnalyticsDataType = .category
    
    enum CodingKeys: String, CodingKey {
        case numberOfTransactions = "totalTxnCount"
        case totalAmount = "totalTxnAmount"
        case date = "date"
        case analytics = "txnAnalytics"
        case monthlyAverage = "monthlyAvgAmount"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        numberOfTransactions = try container.decode(Int.self, forKey: .numberOfTransactions)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        analytics = try container.decode([AnalyticsData].self, forKey: .analytics)
        let dateString = try container.decode(String.self, forKey: .date)
        self.date = Analytics.dateFormatter.date(from: dateString) ?? Date()
        monthlyAverage = try container.decode(Double.self, forKey: .monthlyAverage)
    }
    
    fileprivate init(_ date: Date) {
        numberOfTransactions = 0
        totalAmount = 0
        self.date = date
        analytics = []
        monthlyAverage = 0
    }
    
    fileprivate init(_ transctionCount: Int, totalAmount: Double, date: Date, analytics: [AnalyticsData], average: Double) {
        numberOfTransactions = transctionCount
        self.totalAmount = totalAmount
        self.date = date
        self.analytics = analytics
        self.monthlyAverage = average
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }
    
    static var empty: Analytics {
        return Analytics(Date().startOfMonth)
    }
    
    static func mocked(withDate date: Date) -> Analytics {
        return Analytics(10,
                         totalAmount: 349.87,
                         date: date,
                         analytics: [AnalyticsData.mocked, AnalyticsData.mocked,
                                     AnalyticsData.mocked, AnalyticsData.mocked,
                                     AnalyticsData.mocked],
                         average: 243.09)
    }
    
    static func empty(withDate date: Date) -> Analytics {
        return Analytics(date)
    }
}
