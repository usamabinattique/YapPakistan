//
//  KYCQuestionCellViewModel.swift
//  Adjust
//
//  Created by Sarmad on 06/10/2021.
//

import Foundation
import RxSwift

protocol KYCQuestionCellViewModelInput {
}

protocol KYCQuestionCellViewModelOutput {
    var value: Observable<String> { get }
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

    var inputs: KYCQuestionCellViewModelInput { self }
    var outputs: KYCQuestionCellViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var value: Observable<String> { valueSubject.asObservable() }

    init(value: String) {
        valueSubject.onNext(value)
    }
}
