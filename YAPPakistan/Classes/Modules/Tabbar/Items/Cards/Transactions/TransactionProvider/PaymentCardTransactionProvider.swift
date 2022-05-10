//
//  PaymentCardTransactionProvider.swift
//  YAP
//
//  Created by Wajahat Hassan on 18/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
/// import Networking
/// import YAPKit
import RxSwift

protocol PaymentCardTransactionProvider: AnyObject {
    var transactions: Observable<[TransactionResponse]> { get }
    func fetchTransactions(searchText:String?) -> Observable<Event<PagableResponse<TransactionResponse>>>
    func resetPage(_ page: Int)
    var pageSize: Int { get }
    func resetCardSerialNumber(_ serialNumber: String)
    var currentPage: Int { get }
}

extension PaymentCardTransactionProvider {
    func resetPage(_ page: Int) {}
    var pageSize: Int { return 0 }
    func resetCardSerialNumber(_ serialNumber: String) {}
    var currentPage: Int { return 0 }
}
