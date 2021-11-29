//
//  TitleDetailCellViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 29/11/2021.
//

import Foundation
import RxSwift

protocol TitleDetailCellViewModelInput {
    var selectedObserver: AnyObserver<Bool> { get }
    var titleObserver: AnyObserver<String> { get }
    var detailObserver: AnyObserver<String> { get }
}

protocol TitleDetailCellViewModelOutput {
    var title: Observable<String> { get }
    var detail: Observable<String> { get }
    var selected: Observable<Bool> { get }
}

protocol TitleDetailCellViewModelType {
    var inputs: TitleDetailCellViewModelInput { get }
    var outputs: TitleDetailCellViewModelOutput { get }
}

class TitleDetailCellViewModel: TitleDetailCellViewModelInput,
                                TitleDetailCellViewModelOutput,
                                TitleDetailCellViewModelType {

    // MARK: Properties
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let detailSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)

    var inputs: TitleDetailCellViewModelInput { self }
    var outputs: TitleDetailCellViewModelOutput { self }

    // MARK: Inputs
    var titleObserver: AnyObserver<String> { titleSubject.asObserver() }
    var detailObserver: AnyObserver<String> { detailSubject.asObserver() }
    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }

    // MARK: Outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var detail: Observable<String> { detailSubject.asObservable() }
    var selected: Observable<Bool> { selectedSubject.distinctUntilChanged().asObservable() }

    init() {

    }
}

