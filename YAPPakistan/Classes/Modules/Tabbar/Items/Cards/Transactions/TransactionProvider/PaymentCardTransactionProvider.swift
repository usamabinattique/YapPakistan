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

protocol PaymentCardTransactionProvider: class {
    var transactions: Observable<[TransactionResponse]> { get }
    func fetchTransactions() -> Observable<Event<PagableResponse<TransactionResponse>>>
    func resetPage(_ page: Int)
    var pageSize: Int { get }
}

extension PaymentCardTransactionProvider {
    func resetPage(_ page: Int) {}
    var pageSize: Int { return 0 }
}
