//
//  TransactionFilterSliderCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol TransactionFilterSliderCellViewModelInput {
    var progressObserver: AnyObserver<(minValue: CGFloat, maxValue: CGFloat)> { get }
}

protocol TransactionFilterSliderCellViewModelOutput {
    var title: Observable<String?> { get }
    var range: Observable<String?> { get }
    var progress: Observable<(minValue: CGFloat, maxValue: CGFloat)> { get }
    var selectedRange: Observable<ClosedRange<Double>> { get }
}

protocol TransactionFilterSliderCellViewModelType {
    var inputs: TransactionFilterSliderCellViewModelInput { get }
    var outputs: TransactionFilterSliderCellViewModelOutput { get }
}

class TransactionFilterSliderCellViewModel: TransactionFilterSliderCellViewModelType,
                                            TransactionFilterSliderCellViewModelInput,
                                            TransactionFilterSliderCellViewModelOutput,
                                            ReusableTableViewCellViewModelType {
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionFilterSliderCellViewModelInput { return self }
    var outputs: TransactionFilterSliderCellViewModelOutput { return self }
    var reusableIdentifier: String { return TransactionFilterSliderCell.defaultIdentifier }
    
    private let progressSubject = BehaviorSubject<(minValue: CGFloat, maxValue: CGFloat)>(value: (0, 1))
    private let rangeSubject = BehaviorSubject<String?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: "screen_transaction_filter_display_text_balance".localized)
    private let selectedRangeSubject = BehaviorSubject<ClosedRange<Double>>(value: 0...0)
    
    // MARK: - Inputs
    var progressObserver: AnyObserver<(minValue: CGFloat, maxValue: CGFloat)> { return progressSubject.asObserver() }
    
    // MARK: - Outputs
    var progress: Observable<(minValue: CGFloat, maxValue: CGFloat)> { return progressSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var range: Observable<String?> { return rangeSubject.asObservable() }
    var selectedRange: Observable<ClosedRange<Double>> { return selectedRangeSubject.asObservable() }
    
    // MARK: - Init
    init(_ range: ClosedRange<Double>, _ selectedRange: ClosedRange<Double> = 0...0) {
        
        var selectedRange = selectedRange
        
        if selectedRange.upperBound > range.upperBound {
            selectedRange = selectedRange.lowerBound...range.upperBound
        }
        
        if selectedRange.lowerBound < range.lowerBound {
            selectedRange = range.lowerBound...selectedRange.upperBound
        }
        
        //progressSubject.onNext(CGFloat((selectedRange.upperBound - range.lowerBound)/(range.upperBound - range.lowerBound)))
        
        progressSubject
            .map { "\($0.0) - \($0.1)" }
            .bind(to: rangeSubject).disposed(by: disposeBag)
        
//        selectedRangeSubject
//            .map { String.init(
//            format: "%@ — %@", NumberFormatter.formateAmount(range.lowerBound, fractionDigits: 0),
//            NumberFormatter.formateAmount($0.upperBound, fractionDigits: 0))
//        }
//        .bind(to: rangeSubject).disposed(by: disposeBag)
        
//        progressSubject
//            .map{ range.lowerBound...((Double($0)*(range.upperBound-range.lowerBound))+range.lowerBound) }.bind(to: selectedRangeSubject).disposed(by: disposeBag)
        
    }
}
