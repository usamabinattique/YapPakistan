//
//  LabelCellViewModel.swift
//  Pods
//
//  Created by Sarmad on 20/10/2021.
//

import Foundation
import RxSwift

protocol LabelCellViewModelInput {
}

protocol LabelCellViewModelOutput {
    var value: Observable<String> { get }
}

protocol LabelCellViewModelType {
    var inputs: LabelCellViewModelInput { get }
    var outputs: LabelCellViewModelOutput { get }
}

class LabelCellViewModel: LabelCellViewModelInput,
                                LabelCellViewModelOutput,
                                LabelCellViewModelType {

    var inputs: LabelCellViewModelInput { self }
    var outputs: LabelCellViewModelOutput { self }

    // MARK: Properties
    private let valueSubject = BehaviorSubject<String>(value: "")

    // MARK: Inputs

    // MARK: Outputs
    var value: Observable<String> { valueSubject.asObservable() }

    init(value: String) {
        valueSubject.onNext(value)
    }
}
