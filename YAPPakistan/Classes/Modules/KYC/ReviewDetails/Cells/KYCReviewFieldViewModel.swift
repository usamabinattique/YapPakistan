//
//  KYCReviewFieldViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import Foundation
import RxSwift

protocol KYCReviewFieldViewModelInput {
}

protocol KYCReviewFieldViewModelOutput {
    var heading: Observable<String> { get }
    var value: Observable<String> { get }
}

protocol KYCReviewFieldViewModelType {
    var inputs: KYCReviewFieldViewModelInput { get }
    var outputs: KYCReviewFieldViewModelOutput { get }
}

class KYCReviewFieldViewModel: KYCReviewFieldViewModelInput, KYCReviewFieldViewModelOutput, KYCReviewFieldViewModelType {

    // MARK: Properties

    private let headingSubject = BehaviorSubject<String>(value: "")
    private let valueSubject = BehaviorSubject<String>(value: "")

    var inputs: KYCReviewFieldViewModelInput { self }
    var outputs: KYCReviewFieldViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var heading: Observable<String> { headingSubject.asObservable() }
    var value: Observable<String> { valueSubject.asObservable() }

    init(heading: String, value: String) {
        headingSubject.onNext(heading)
        valueSubject.onNext(value)
    }
}
