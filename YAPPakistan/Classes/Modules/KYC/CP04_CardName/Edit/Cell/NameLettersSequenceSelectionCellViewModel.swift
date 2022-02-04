//
//  NameLettersSequenceSelectionCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 04/02/2022.
//

import Foundation
import YAPComponents
import RxSwift

protocol NameLettersSequenceSelectionCellViewModelInput {
    var checkObserver: AnyObserver<Bool> { get }
    var selectedObserver: AnyObserver<Void> { get }
}

protocol NameLettersSequenceSelectionCellViewModelOutput {
    var check: Observable<Bool> { get }
    var title: Observable<String?> { get }
}

protocol NameLettersSequenceSelectionCellViewModelType {
    var inputs: NameLettersSequenceSelectionCellViewModelInput { get }
    var outputs: NameLettersSequenceSelectionCellViewModelOutput { get }
}

class NameLettersSequenceSelectionCellViewModel: NameLettersSequenceSelectionCellViewModelType,
                                                 NameLettersSequenceSelectionCellViewModelInput,
                                                 NameLettersSequenceSelectionCellViewModelOutput,
                                              ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: NameLettersSequenceSelectionCellViewModelInput { return self }
    var outputs: NameLettersSequenceSelectionCellViewModelOutput { return self }
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
    init(type: NameSequence) {
        selectedSubject.withLatestFrom(checkSubject).map{ !$0 }.bind(to: checkSubject).disposed(by: disposeBag)
        checkSubject.onNext(type.isChecked)
        titleSubject.onNext(type.nameFormatted)
    }
}
