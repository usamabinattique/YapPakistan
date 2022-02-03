//
//  CardSchemeViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol CardSchemeViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol CardSchemeViewModelOutput {
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { get }
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
}

protocol CardSchemeViewModelType {
    var inputs: CardSchemeViewModelInput { get }
    var outputs: CardSchemeViewModelOutput { get }
}

class CardSchemeViewModel: CardSchemeViewModelType, CardSchemeViewModelInput, CardSchemeViewModelOutput {
    

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { optionViewModelsSubject.asObservable() }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    // MARK: Subjects
    var optionViewModelsSubject = BehaviorSubject<[CardSchemeCellViewModel]>(value: [])
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()

    var inputs: CardSchemeViewModelInput { return self }
    var outputs: CardSchemeViewModelOutput { return self }

    var accountProvider: AccountProvider!
    let disposeBag = DisposeBag()
    
    init(accountProvider: AccountProvider,
         cellViewModel: Observable<[CardSchemeCellViewModel]>) {
        self.accountProvider = accountProvider
        
        optionViewModelsSubject.onNext([CardSchemeCellViewModel(), CardSchemeCellViewModel()])
        
    }
}
