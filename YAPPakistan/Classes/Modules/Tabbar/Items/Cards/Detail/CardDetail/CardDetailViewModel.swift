//
//  CardDetailViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CardDetailViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var detailsObserver: AnyObserver<Void> { get }
    var freezObserver: AnyObserver<Void> { get }
    var limitObserver: AnyObserver<Void> { get }
}

protocol CardDetailViewModelOutputs {
    var back: Observable<Void> { get }
    var details: Observable<Void> { get }
    var freez: Observable<Void> { get }
    var limit: Observable<Void> { get }
}

protocol CardDetailViewModelType {
    var inputs: CardDetailViewModelInputs { get }
    var outputs: CardDetailViewModelOutputs { get }
}

struct CardDetailViewModel: CardDetailViewModelType, CardDetailViewModelInputs, CardDetailViewModelOutputs {

    var backSubject = PublishSubject<Void>()
    var detailsSubject = PublishSubject<Void>()
    var freezSubject = PublishSubject<Void>()
    var limitSubject = PublishSubject<Void>()

    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var detailsObserver: AnyObserver<Void> { detailsSubject.asObserver() }
    var freezObserver: AnyObserver<Void> { freezSubject.asObserver() }
    var limitObserver: AnyObserver<Void> { limitSubject.asObserver() }

    var back: Observable<Void> { backSubject.asObservable() }
    var details: Observable<Void> { detailsSubject.asObservable() }
    var freez: Observable<Void> { freezSubject.asObservable() }
    var limit: Observable<Void> { limitSubject.asObservable() }

    var inputs: CardDetailViewModelInputs { self }
    var outputs: CardDetailViewModelOutputs { self }

}
