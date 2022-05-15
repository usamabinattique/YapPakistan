//
//  AnalyticsRepository.swift
//  YAP
//
//  Created by Zain on 25/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol AnalyticsRepositoryType {
    func analyticsByCategory(_ date: Date, _ cardSerialNo: String) -> Observable<Event<Analytics?>>
    func analyticsByMerchant(_ date: Date, _ cardSerialNo: String) -> Observable<Event<Analytics?>>
    func fetchMerchantAnalytics(_ date: Date, _ cardSerialNo: String, categories: [String]?) -> Observable<Event<MerchantCategoryDetail?>>
    func fetchCategorynalytics(_ date: Date, _ cardSerialNo: String, categories: [Int?]) -> Observable<Event<MerchantCategoryDetail?>>
}

class AnalyticsRepository: AnalyticsRepositoryType {

    private let service: TransactionsService

    init(service: TransactionsService) {
        self.service = service
    }
    
    func analyticsByCategory(_ date: Date, _ cardSerialNo: String) -> Observable<Event<Analytics?>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return service.getTransactionsByCategory(date: formatter.string(from: date)).materialize()
    }
    
    func analyticsByMerchant(_ date: Date, _ cardSerialNo: String) -> Observable<Event<Analytics?>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return service.getTransactionsByMerchant(date: formatter.string(from: date)).materialize()
    }
    
    func fetchMerchantAnalytics(_ date: Date, _ cardSerialNo: String, categories: [String]?) -> Observable<Event<MerchantCategoryDetail?>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return service.fetchMerchantAnalytics(cardSerialNo: cardSerialNo, date: formatter.string(from: date), categories: categories).materialize()
    }
    
    func fetchCategorynalytics(_ date: Date, _ cardSerialNo: String, categories: [Int?]) -> Observable<Event<MerchantCategoryDetail?>> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return service.fetchCategoryAnalytics(cardSerialNo: cardSerialNo, date: formatter.string(from: date), categories: categories).materialize()
    }
}
