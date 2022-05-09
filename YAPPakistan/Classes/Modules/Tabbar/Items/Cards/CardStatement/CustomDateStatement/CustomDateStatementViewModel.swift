//
//  CustomDateStatementViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 06/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

typealias DateRangeSelected = (startDate:String, endDate:String)

protocol CustomDateStatementViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var startDateObserver: AnyObserver<Date?> { get }
    var endDateObserver: AnyObserver<Date?> { get }
    var nextObserver: AnyObserver<Void> { get }
}

protocol CustomDateStatementViewModelOutput {
    var back: Observable<Void> { get }
    var title: Observable<String> { get }
    var startDateValue: Observable<String> { get }
    var endDateValue: Observable<String> { get }
    var next: Observable<DateRangeSelected> { get }
    var isDateValid: Observable<Bool> { get }
}

protocol CustomDateStatementViewModelType {
    var inputs: CustomDateStatementViewModelInput { get }
    var outputs: CustomDateStatementViewModelOutput { get }
}

class CustomDateStatementViewModel: CustomDateStatementViewModelType, CustomDateStatementViewModelInput, CustomDateStatementViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: CustomDateStatementViewModelInput { return self }
    var outputs: CustomDateStatementViewModelOutput { return self }
    
    private var startDate = Date()
    private var endDate = Date()
    
    // MARK: Subjects
    private let backSubject = PublishSubject<Void>()
    private let startDateSubject = BehaviorSubject<Date?>(value: nil)
    private let startDateValueSubject = BehaviorSubject<String>(value: "")
    private let endDateSubject = BehaviorSubject<Date?>(value: nil)
    private let endDateValueSubject = BehaviorSubject<String>(value: "")
    private let nextSubject = PublishSubject<Void>()
    private let generateStatementSubject = PublishSubject<DateRangeSelected>()
    private let isValidDatesSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var startDateObserver: AnyObserver<Date?> { startDateSubject.asObserver() }
    var endDateObserver: AnyObserver<Date?> { endDateSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    
    // MARK: Outputs
    var back: Observable<Void> { return backSubject.asObservable() }
    var title: Observable<String> { Observable.just("Custom date statement") }
    var startDateValue: Observable<String> { startDateValueSubject.asObservable() }
    var endDateValue: Observable<String> { endDateValueSubject.asObservable() }
    var next: Observable<DateRangeSelected> { generateStatementSubject.asObservable() }
    var isDateValid: Observable<Bool> { isValidDatesSubject.asObservable() }
    
    init() {
        
        startDateSubject
            .subscribe(onNext: { [weak self] date in
                let dateFormatter = DateFormatter.appReadableDateFormatter
                if let newDate = date {
                    let dateString = dateFormatter.string(from: newDate)
                    self?.startDateValueSubject.onNext(dateString)
                }
            }).disposed(by: disposeBag)
        
        endDateSubject
            .subscribe(onNext: { [weak self] date in
                let dateFormatter = DateFormatter.appReadableDateFormatter
                if let newDate = date {
                    let dateString = dateFormatter.string(from: newDate)
                    self?.endDateValueSubject.onNext(dateString)
                }
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(startDateSubject, endDateSubject)
            .subscribe(onNext: { [weak self] startD, endD in
                guard let startDate = startD else { return }
                guard let endDate = endD else { return }
                
                self?.startDate = startDate
                self?.endDate = endDate
                
                if startDate.unixTimestamp < endDate.unixTimestamp {
                    self?.isValidDatesSubject.onNext(true)
                } else {
                    self?.isValidDatesSubject.onNext(false)
                }
            }).disposed(by: disposeBag)
        
        nextSubject
            .subscribe(onNext: { [weak self] _ in
                let startDateString = self!.startDate.string(withFormat: DateFormatter.serverReadableDateFormat)
                let endDateString = self!.endDate.string(withFormat: DateFormatter.serverReadableDateFormat)
                
                self?.generateStatementSubject.onNext((startDate: startDateString, endDate: endDateString))
            })
            .disposed(by: disposeBag)
    }
}
