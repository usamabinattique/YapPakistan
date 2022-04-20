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



import Foundation
import YAPComponents
import RxSwift

protocol HideWidgetBottomSheetCellViewModelInput {
    var gotItObserver: AnyObserver<Void> { get }
    var cancelObserver: AnyObserver<Void> { get }
}

protocol HideWidgetBottomSheetCellViewModelOutput {
    var description: Observable<String> { get }
    var gotIt: Observable<Void> { get }
    var cancel: Observable<Void> { get }
}

protocol HideWidgetBottomSheetCellViewModelType {
    var inputs: HideWidgetBottomSheetCellViewModelInput { get }
    var outputs: HideWidgetBottomSheetCellViewModelOutput { get }
}

class HideWidgetBottomSheetCellViewModel: HideWidgetBottomSheetCellViewModelType, HideWidgetBottomSheetCellViewModelInput, HideWidgetBottomSheetCellViewModelOutput, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String  { HideWidgetBottomSheetCell.defaultIdentifier }
    
    
    // MARK: - Propertiesfileprivate var limitSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    fileprivate let descriptionSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let gotItSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    
    // Inputs
    var gotItObserver: AnyObserver<Void> { gotItSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { cancelSubject.asObserver() }

    // Outputs
    var description: Observable<String> { descriptionSubject.asObservable() }
    var gotIt: Observable<Void> { gotItSubject.asObservable() }
    var cancel: Observable<Void> { cancelSubject.asObservable() }

    var inputs: HideWidgetBottomSheetCellViewModelInput { self }
    var outputs: HideWidgetBottomSheetCellViewModelOutput { self }

    // Properties
    private let disposeBag = DisposeBag()

    init() {
       let description = "screen_hide_widget_popup_description".localized
        descriptionSubject.onNext(description)

    }
}
