//
//  StatementsRepository.swift
//  YAPPakistan
//
//  Created by Umair  on 29/04/2022.
//

import Foundation
import RxSwift

public protocol StatementsRepositoryType {
    func getCardStatement(serialNumber: String) -> Observable<Event<[Statement]?>>
    func getCustomCardStatement(serialNumber: String, startDate: String, endDate: String) -> Observable<Event<Statement?>>
    func getAccountStatement() -> Observable<Event<[Statement]?>>
    func getWalletStatement() -> Observable<Event<[Statement]?>>
}

public extension StatementsRepositoryType {
    func getCardStatement(serialNumber: String) -> Observable<Event<[Statement]?>> { .never() }
    func getAccountStatement() -> Observable<Event<[Statement]?>> { .never() }
    func getWalletStatement() -> Observable<Event<[Statement]?>> { .never() }
}
