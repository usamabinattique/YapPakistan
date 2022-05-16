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
//    var progressObserver: AnyObserver<CGFloat> { get }
    var resetRangeObserver: AnyObserver<(minValue: CGFloat, maxValue: CGFloat)> { get }
}

protocol TransactionFilterSliderCellViewModelOutput {
  /*  var title: Observable<String?> { get }
    var range: Observable<String?> { get }
    var progress: Observable<(minValue: CGFloat, maxValue: CGFloat)> { get }
    var selectedRange: Observable<ClosedRange<Double>> { get } */
    
    var title: Observable<String?> { get }
    var range: Observable<String?> { get }
//    var progress: Observable<CGFloat> { get }
    var progress: Observable<(minValue: CGFloat, maxValue: CGFloat)> { get }
    var selectedRange: Observable<ClosedRange<Double>> { get }
    var filterTotalRange: Observable<(minValue: CGFloat, maxValue: CGFloat)> { get }
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
    
    private let progressSubject = ReplaySubject<(minValue: CGFloat, maxValue: CGFloat)>.create(bufferSize: 1)
    private let rangeSubject = BehaviorSubject<(minValue: CGFloat, maxValue: CGFloat)>(value: (0, 3500))
    private let titleSubject = BehaviorSubject<String?>(value: "screen_transaction_filter_display_text_balance".localized)
    private let selectedRangeSubject = BehaviorSubject<ClosedRange<Double>>(value: 0...0)
    private let rangeAlways = BehaviorSubject<String?>(value:  String(format: "%@ — %@",
                                                                      NumberFormatter.formateAmount(Double(0), fractionDigits: 0),
                                                                      NumberFormatter.formateAmount(Double(1001), fractionDigits: 0)))
    
    // MARK: - Inputs
    var progressObserver: AnyObserver<(minValue: CGFloat, maxValue: CGFloat)> { return progressSubject.asObserver() }
    var resetRangeObserver: AnyObserver<(minValue: CGFloat, maxValue: CGFloat)> { rangeSubject.asObserver() }
    // MARK: - Outputs
    
    
    
  //  var progress: Observable<CGFloat> { return progressSubject.asObservable() }
    var progress: Observable<(minValue: CGFloat, maxValue: CGFloat)> { return progressSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
   var range: Observable<String?> { return rangeSubject.asObservable().map {
        return String(format: "%@ — %@",
                      NumberFormatter.formateAmount(Double($0), fractionDigits: 0),
                      NumberFormatter.formateAmount(Double($1), fractionDigits: 0))} }
//    var range: Observable<String?> { return selectedRangeSubject.asObservable().map {
//         return String(format: "%@ — %@",
//                       NumberFormatter.formateAmount(Double($0), fractionDigits: 0),
//                       NumberFormatter.formateAmount(Double($1), fractionDigits: 0))} }
    var selectedRange: Observable<ClosedRange<Double>> { return selectedRangeSubject.asObservable() }
    var filterTotalRange: Observable<(minValue: CGFloat, maxValue: CGFloat)> { rangeSubject.asObservable() }
    
    // MARK: - Init
    init(_ range: ClosedRange<Double>, _ selectedRange: ClosedRange<Double> = 0...0) {
        
        var selectedRange = selectedRange
        
    /*    if selectedRange.upperBound > range.upperBound {
            selectedRange = selectedRange.lowerBound...range.upperBound
        }
        
        if selectedRange.lowerBound < range.lowerBound {
            selectedRange = range.lowerBound...selectedRange.upperBound
        } */
        
        
        progressSubject.onNext((minValue: CGFloat(selectedRange.lowerBound), maxValue: CGFloat(range.upperBound)))

        let progressSubjectShare = progressSubject.share()
        progressSubjectShare.skip(while: { (minValue: CGFloat, maxValue: CGFloat) in
            maxValue <= minValue
        }).map { (minValue: CGFloat, maxValue: CGFloat) in
            return  Double(minValue)...Double(maxValue > 0 ? maxValue : 0)
            
        }.bind(to: selectedRangeSubject).disposed(by: disposeBag)
        
        progressSubjectShare.bind(to: rangeSubject).disposed(by: disposeBag)
        
    }
    
    init(_ range: ClosedRange<Double>, _ selectedRange: ClosedRange<Double> = 0...0, isHomeSearch: Bool) {
        
        var selectedRange = selectedRange
        
       
//        progressSubject.onNext((minValue: CGFloat(selectedRange.lowerBound), maxValue: CGFloat(range.upperBound)))

       // let progressSubjectShare = progressSubject.share()
//        progressSubjectShare.skip(while: { (minValue: CGFloat, maxValue: CGFloat) in
//            maxValue <= minValue
//        }).map { (minValue: CGFloat, maxValue: CGFloat) in
//            return  Double(minValue)...Double(maxValue > 0 ? maxValue : 0)
//
//        }.bind(to: selectedRangeSubject).disposed(by: disposeBag)
        
//        progressSubjectShare.map { (minValue: CGFloat, maxValue: CGFloat) in
//            return  Double(minValue)...Double(maxValue > 0 ? maxValue : 0)
//
//        }.bind(to: selectedRangeSubject).disposed(by: disposeBag)
        
        
       // progressSubjectShare.bind(to: rangeSubject).disposed(by: disposeBag)
        
        if selectedRange.upperBound > range.upperBound {
                selectedRange = selectedRange.lowerBound...range.upperBound
            }
            
            if selectedRange.lowerBound < range.lowerBound {
                selectedRange = range.lowerBound...selectedRange.upperBound
            }
        
       rangeSubject.onNext((minValue: CGFloat(selectedRange.lowerBound), maxValue: CGFloat(selectedRange.upperBound)))
        
        progressSubject.map { (minValue: CGFloat, maxValue: CGFloat) in
            guard minValue < maxValue else { return Double(selectedRange.lowerBound)...Double(selectedRange.upperBound) }
            return  Double(minValue)...Double(maxValue > 0 ? maxValue : 0)
        }.bind(to: selectedRangeSubject).disposed(by: disposeBag)
        
        selectedRangeSubject.subscribe(onNext: { [weak self] closedRange in
            print("range: selected closed range \(closedRange)")
        }).disposed(by: disposeBag)
        
        progressSubject.subscribe(onNext: { [weak self] closedRange in
            print("range: progress range \(closedRange)")
        }).disposed(by: disposeBag)
        
        
    /*    if selectedRange.upperBound > range.upperBound {
            selectedRange = selectedRange.lowerBound...range.upperBound
        }
        
        if selectedRange.lowerBound < range.lowerBound {
            selectedRange = range.lowerBound...selectedRange.upperBound
        }
        
      //  progressSubject.onNext(CGFloat((selectedRange.upperBound - range.lowerBound)/(range.upperBound - range.lowerBound)))
        progressSubject.onNext((minValue: CGFloat(range.lowerBound), maxValue: CGFloat(range.upperBound)))
        
        
        progressSubject.map { range.lowerBound...((Double($0)*(range.upperBound-range.lowerBound))+range.lowerBound) }.bind(to: selectedRangeSubject).disposed(by: disposeBag) */
    }
}
