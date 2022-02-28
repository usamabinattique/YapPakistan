//
//  CardSchemeCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 02/02/2022.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

protocol CardSchemeCellViewModelInput {
    var buttonTapObserver: AnyObserver<KYCCardsSchemeM> { get }
}

protocol CardSchemeCellViewModelOutput {
    var selected: Observable<KYCCardsSchemeM> { get }
    var title: Observable<String> { get }
    var description: Observable<String> { get }
    var buttonTitle: Observable<String> { get }
    var cardImage: Observable<String> { get }
    var cardScheme: Observable<KYCCardsSchemeM> { get }
}

protocol CardSchemeCellViewModelType {
    var inputs: CardSchemeCellViewModelInput { get }
    var outputs: CardSchemeCellViewModelOutput { get }
}

class CardSchemeCellViewModel: CardSchemeCellViewModelType, CardSchemeCellViewModelInput, CardSchemeCellViewModelOutput {
    
    //MARK: Properties
    
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = PublishSubject<KYCCardsSchemeM>()
    
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let descriptionSubject = BehaviorSubject<String>(value: "")
    private let buttonTitleSubject = BehaviorSubject<String>(value: "")
    private let cardImageSubject = BehaviorSubject<String>(value: "")
    
    private var schemeModel: KYCCardsSchemeM!
    
    var inputs: CardSchemeCellViewModelInput { self }
    var outputs: CardSchemeCellViewModelOutput { self }
    
    //MARK: Inputs
    var buttonTapObserver: AnyObserver<KYCCardsSchemeM> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var selected: Observable<KYCCardsSchemeM> { selectedSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var description: Observable<String> { descriptionSubject.asObservable() }
    var buttonTitle: Observable<String> { buttonTitleSubject.asObservable() }
    var cardImage: Observable<String> { cardImageSubject.asObservable() }
    var cardScheme: Observable<KYCCardsSchemeM> { Observable.just(schemeModel) }
    
    init(_ schemeModel: KYCCardsSchemeM) {
        
        self.schemeModel = schemeModel
        
        titleSubject.onNext(schemeModel.cardTitle ?? "")
        descriptionSubject.onNext(schemeModel.cardDescription ?? "")
        buttonTitleSubject.onNext(schemeModel.cardButtonTitle ?? "")
        cardImageSubject.onNext(schemeModel.cardImage ?? "")
        
        
    }
    
}
