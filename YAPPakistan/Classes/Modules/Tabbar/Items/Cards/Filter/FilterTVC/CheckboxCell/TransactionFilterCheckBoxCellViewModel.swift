//
//  File.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol TransactionFilterCheckBoxCellViewModelInput {
    var checkObserver: AnyObserver<Bool> { get }
    var selectedObserver: AnyObserver<Void> { get }
}

protocol TransactionFilterCheckBoxCellViewModelOutput {
    var check: Observable<Bool> { get }
    var title: Observable<String?> { get }
}

protocol TransactionFilterCheckBoxCellViewModelType {
    var inputs: TransactionFilterCheckBoxCellViewModelInput { get }
    var outputs: TransactionFilterCheckBoxCellViewModelOutput { get }
}

class TransactionFilterCheckBoxCellViewModel: TransactionFilterCheckBoxCellViewModelType,
                                              TransactionFilterCheckBoxCellViewModelInput,
                                              TransactionFilterCheckBoxCellViewModelOutput,
                                              ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionFilterCheckBoxCellViewModelInput { return self }
    var outputs: TransactionFilterCheckBoxCellViewModelOutput { return self }
    var reusableIdentifier: String { return TransactionFilterCheckBoxCell.defaultIdentifier }
    
    private let checkSubject = BehaviorSubject<Bool>(value: false)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let selectedSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var checkObserver: AnyObserver<Bool> { return checkSubject.asObserver() }
    var selectedObserver: AnyObserver<Void> { selectedSubject.asObserver() }
    
    // MARK: - Outputs
    var check: Observable<Bool> { return checkSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    
    // MARK: - Init
    init(_ type: TransactionFilterType) {
        selectedSubject.withLatestFrom(checkSubject).map{ !$0 }.bind(to: checkSubject).disposed(by: disposeBag)
        checkSubject.onNext(type.isChecked)
        titleSubject.onNext(type.title)
    }
    
    init(_ type: HomeTransactionFilterType) {
        selectedSubject.withLatestFrom(checkSubject).map{ !$0 }.bind(to: checkSubject).disposed(by: disposeBag)
        checkSubject.onNext(type.isChecked)
        titleSubject.onNext(type.title)
    }
}
