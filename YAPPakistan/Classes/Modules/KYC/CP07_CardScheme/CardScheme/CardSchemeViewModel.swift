//
//  CardSchemeViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents

protocol CardSchemeViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var fetchCardsObserver: AnyObserver<Void> { get }
}

protocol CardSchemeViewModelOutput {
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { get }
    var heading: Observable<String?> { get }
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
}

protocol CardSchemeViewModelType {
    var inputs: CardSchemeViewModelInput { get }
    var outputs: CardSchemeViewModelOutput { get }
}

class CardSchemeViewModel: CardSchemeViewModelType, CardSchemeViewModelInput, CardSchemeViewModelOutput {
    
    // MARK: Subjects
    var optionViewModelsSubject = BehaviorSubject<[CardSchemeCellViewModel]>(value: [])
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var fetchCardSubject = PublishSubject<Void>()
    
    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var fetchCardsObserver: AnyObserver<Void> { fetchCardSubject.asObserver() }
    
    // MARK: Outputs
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { optionViewModelsSubject.asObservable() }
    var heading: Observable<String?> { Observable.just("Select a card".localized) }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    
    var inputs: CardSchemeViewModelInput { return self }
    var outputs: CardSchemeViewModelOutput { return self }

    var accountProvider: AccountProvider!
    let disposeBag = DisposeBag()
    
    init(_ repository: KYCRepository, accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
        
        fetchCardsActiveScheme(repository)
    }
}

extension CardSchemeViewModel {
    
    func fetchCardsActiveScheme(_ repository: KYCRepository) {
        
        let cardsRequest = fetchCardSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap{ repository.fetchCardScheme() }
            .share()
        
        cardsRequest.subscribe(onNext: { _ in
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
        
        cardsRequest.elements()
            .map { $0.map { CardSchemeCellViewModel($0) } }.bind(to: optionViewModelsSubject).disposed(by: disposeBag)
        
        cardsRequest.errors().subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
        
//        cardsRequest.errors().map{ $0.localizedDescription }
//        .bind(to: error)
    }
    
}
