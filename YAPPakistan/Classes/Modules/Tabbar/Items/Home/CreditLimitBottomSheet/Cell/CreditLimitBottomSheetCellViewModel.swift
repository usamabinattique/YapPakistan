//
//  CreditLimitBottomSheetCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 01/04/2022.
//

import Foundation
import YAPComponents
import RxSwift

protocol CreditLimitBottomSheetCellViewModelInput {
    var gotItObserver: AnyObserver<Void> { get }
}

protocol CreditLimitBottomSheetCellViewModelOutput {
    var description: Observable<String> { get }
    var gotIt: Observable<Void> { get }
}

protocol CreditLimitBottomSheetCellViewModelType {
    var inputs: CreditLimitBottomSheetCellViewModelInput { get }
    var outputs: CreditLimitBottomSheetCellViewModelOutput { get }
}

class CreditLimitBottomSheetCellViewModel: CreditLimitBottomSheetCellViewModelType, CreditLimitBottomSheetCellViewModelInput, CreditLimitBottomSheetCellViewModelOutput, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String  { CreditLimitBottomSheetCell.defaultIdentifier }
    
    
    // MARK: - Propertiesfileprivate var limitSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    fileprivate let descriptionSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let gotItSubject = PublishSubject<Void>()
    
    // Inputs
    var gotItObserver: AnyObserver<Void> { gotItSubject.asObserver() }

    // Outputs
    var description: Observable<String> { descriptionSubject.asObservable() }
    var gotIt: Observable<Void> { gotItSubject.asObservable() }

    var inputs: CreditLimitBottomSheetCellViewModelInput { self }
    var outputs: CreditLimitBottomSheetCellViewModelOutput { self }

    // Properties
    private let disposeBag = DisposeBag()

    init() {
       let description = "Just to let you know, we’ll upgrade your top up limit once we’ve successfully approved your account."
        descriptionSubject.onNext(description)

    }
}
