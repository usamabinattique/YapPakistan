//
//  KYCQuestionCellViewModel.swift
//  Adjust
//
//  Created by Sarmad on 06/10/2021.
//

import Foundation
import RxSwift

protocol KYCQuestionCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol KYCQuestionCellViewModelOutput {
    var value: Observable<String> { get }
    var selected: Observable<Bool> { get }
}

protocol KYCQuestionCellViewModelType {
    var inputs: KYCQuestionCellViewModelInput { get }
    var outputs: KYCQuestionCellViewModelOutput { get }
}

class KYCQuestionCellViewModel: KYCQuestionCellViewModelInput,
                                KYCQuestionCellViewModelOutput,
                                KYCQuestionCellViewModelType {
    // MARK: Properties
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)

    var inputs: KYCQuestionCellViewModelInput { self }
    var outputs: KYCQuestionCellViewModelOutput { self }

    // MARK: Inputs

    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }

    // MARK: Outputs

    var value: Observable<String> { valueSubject.asObservable() }
    var selected: Observable<Bool> { selectedSubject.asObservable() }

    init(value: String) {
        valueSubject.onNext(value)
    }
}
