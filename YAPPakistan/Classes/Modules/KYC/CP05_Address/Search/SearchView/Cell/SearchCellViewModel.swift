//
//  SearchCellViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 03/11/2021.
//

import Foundation
import RxSwift

protocol SearchCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol SearchCellViewModelOutput {
    var value: Observable<String> { get }
    var selected: Observable<Bool> { get }
}

protocol SearchCellViewModelType {
    var inputs: SearchCellViewModelInput { get }
    var outputs: SearchCellViewModelOutput { get }
}

class SearchCellViewModel: SearchCellViewModelInput,
                                SearchCellViewModelOutput,
                                SearchCellViewModelType {
    // MARK: Properties
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)

    var inputs: SearchCellViewModelInput { self }
    var outputs: SearchCellViewModelOutput { self }

    // MARK: Inputs

    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }

    // MARK: Outputs

    var value: Observable<String> { valueSubject.asObservable() }
    var selected: Observable<Bool> { selectedSubject.asObservable() }

    init(value: String) {
        valueSubject.onNext(value)
    }
}
