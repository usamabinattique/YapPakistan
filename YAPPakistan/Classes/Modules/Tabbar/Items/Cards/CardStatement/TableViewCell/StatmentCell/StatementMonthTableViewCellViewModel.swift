//
//  StatementMonthTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 17/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol StatementMonthTableViewCellViewModelInput {
    var viewObserver: AnyObserver<Void> { get }
}

protocol StatementMonthTableViewCellViewModelOutput {
    var viewStatement: Observable<Statement> { get }
    var month: Observable<String> { get }
}

protocol StatementMonthTableViewCellViewModeltype {
    var inputs: StatementMonthTableViewCellViewModelInput { get }
    var outputs: StatementMonthTableViewCellViewModelOutput { get }
}

class StatementMonthTableViewCellViewModel: ReusableTableViewCellViewModelType, StatementMonthTableViewCellViewModeltype, StatementMonthTableViewCellViewModelInput, StatementMonthTableViewCellViewModelOutput {
    
    var reusableIdentifier: String { return StatementMonthTableViewCell.defaultIdentifier }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: StatementMonthTableViewCellViewModelInput { return self }
    var outputs: StatementMonthTableViewCellViewModelOutput { return self }
    
    private let viewObserverSubject = PublishSubject<Void>()
    
    private let viewStatementSubject = PublishSubject<Statement>()
    private let monthSubject = BehaviorSubject<String>(value: "")
    
    // MARK: - Inputs
    var viewObserver: AnyObserver<Void> { return viewObserverSubject.asObserver() }
    
    // MARK: - Outputs
    var viewStatement: Observable<Statement> { return viewStatementSubject.asObservable() }
    var month: Observable<String> { return monthSubject.asObservable() }
    
    // MARK: - Init
    init(_ statement: Statement) {
        
        monthSubject.onNext(statement.month ?? "")
        
        viewObserverSubject.map { statement }.bind(to: viewStatementSubject).disposed(by: disposeBag)
    }
}
