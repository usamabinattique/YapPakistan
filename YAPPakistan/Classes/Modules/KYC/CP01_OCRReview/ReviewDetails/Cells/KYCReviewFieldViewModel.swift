//
//  KYCReviewFieldViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import Foundation
import RxSwift

protocol KYCReviewFieldViewModelInput {
    var valueUpdated: AnyObserver<String> { get }
}

protocol KYCReviewFieldViewModelOutput {
    var heading: Observable<String> { get }
    var value: Observable<String> { get }
    var isValueEditable: Observable<Bool> { get }
}

protocol KYCReviewFieldViewModelType {
    var inputs: KYCReviewFieldViewModelInput { get }
    var outputs: KYCReviewFieldViewModelOutput { get }
}

class KYCReviewFieldViewModel: KYCReviewFieldViewModelInput, KYCReviewFieldViewModelOutput, KYCReviewFieldViewModelType {

    // MARK: Properties

    private let headingSubject = BehaviorSubject<String>(value: "")
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let valueFieldEditableSubject = BehaviorSubject<Bool>(value: false)
    private let valueChangedSubject = BehaviorSubject<String>(value: "")
    
    private let disposeBag = DisposeBag()

    var inputs: KYCReviewFieldViewModelInput { self }
    var outputs: KYCReviewFieldViewModelOutput { self }

    // MARK: Inputs
    var valueUpdated: AnyObserver<String> { valueChangedSubject.asObserver() }
    
    // MARK: Outputs

    var heading: Observable<String> { headingSubject.asObservable() }
    var value: Observable<String> { valueSubject.asObservable() }
    var isValueEditable: Observable<Bool> { valueFieldEditableSubject.asObservable() }

    init(heading: String, value: String, valueChanged: AnyObserver<String>? = nil, isEditable: Bool? = false) {
        headingSubject.onNext(heading)
        valueSubject.onNext(value)
        valueFieldEditableSubject.onNext(isEditable ?? false)
        if let observer = valueChanged {
//            valueChangedSubject
//                .subscribe(onNext: {
//                    print($0)
//                }).disposed(by: disposeBag)
            valueChangedSubject.bind(to: observer).disposed(by: disposeBag)
        }
    }
}
