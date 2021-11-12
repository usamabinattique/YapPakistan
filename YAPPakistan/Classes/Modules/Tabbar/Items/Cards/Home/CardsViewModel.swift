//
//  CardsViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol CardsViewModelInputs {
    var detailsObservers: AnyObserver<Void> { get }
}

protocol CardsViewModelOutputs {
    var details: Observable<Void> { get }
}

protocol CardsViewModelType {
    var inputs: CardsViewModelInputs { get }
    var outputs: CardsViewModelOutputs { get }
}

class CardsViewModel: CardsViewModelType, CardsViewModelInputs, CardsViewModelOutputs {

    var inputs: CardsViewModelInputs { self }
    var outputs: CardsViewModelOutputs { self }

    // MARK: Inputs
    var detailsObservers: AnyObserver<Void> { detailsSubject.asObserver() }

    // MARK: Outputs
    var details: Observable<Void> { detailsSubject.asObservable() }

    // MARK: Subjects
    var detailsSubject = PublishSubject<Void>()

    // MARK: - Properties
    let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

    }
}

