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
    //var nextObserver: AnyObserver<CardSchemeCellViewModel> { get }
    var backObserver: AnyObserver<Void> { get }
    var fetchCardsObserver: AnyObserver<Void> { get }
}

protocol CardSchemeViewModelOutput {
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { get }
    var heading: Observable<String?> { get }
    var next: Observable<KYCCardsSchemeM> { get }
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
}

protocol CardSchemeViewModelType {
    var inputs: CardSchemeViewModelInput { get }
    var outputs: CardSchemeViewModelOutput { get }
}

class CardSchemeViewModel: CardSchemeViewModelType, CardSchemeViewModelInput, CardSchemeViewModelOutput {
    
    
    // MARK: Subjects
    var optionViewModelsSubject = BehaviorSubject<[CardSchemeCellViewModel]>(value: [])
    private var nextSubject = PublishSubject<KYCCardsSchemeM>()
    private var backSubject = PublishSubject<Void>()
    private var fetchCardSubject = PublishSubject<Void>()
    private var errorSubject = PublishSubject<String>()
    
    var inputs: CardSchemeViewModelInput { return self }
    var outputs: CardSchemeViewModelOutput { return self }
    
    // MARK: Inputs
    //var nextObserver: AnyObserver<SchemeType> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var fetchCardsObserver: AnyObserver<Void> { fetchCardSubject.asObserver() }
    
    // MARK: Outputs
    var optionsViewModel: Observable<[CardSchemeCellViewModel]> { optionViewModelsSubject.asObservable() }
    var heading: Observable<String?> { Observable.just("screen_kyc_card_scheme_screen_title".localized) }
    var next: Observable<KYCCardsSchemeM> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }

    var accountProvider: AccountProvider!
    let disposeBag = DisposeBag()
    
    init(_ repository: KYCRepository, accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
        
        fetchCardsActiveScheme(repository)
        
        optionViewModelsSubject.subscribe(onNext: { [weak self] schemeObjs in
            guard let `self` = self else { return }
            for scheme in schemeObjs {
                scheme.outputs.selected.bind(to: self.nextSubject).disposed(by: self.disposeBag)
            }
        })
            .disposed(by: disposeBag)
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
            .map { $0.map { CardSchemeCellViewModel($0) } }
            .bind(to: optionViewModelsSubject)
            .disposed(by: disposeBag)
        
        cardsRequest.errors()
            .map{ $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
}
