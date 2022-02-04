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
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol CardSchemeCellViewModelOutput {
    var value: Observable<String> { get }
    var selected: Observable<Bool> { get }
    var title: Observable<String> { get }
    var description: Observable<String> { get }
    var buttonTitle: Observable<String> { get }
    var cardImage: Observable<String> { get }
}

protocol CardSchemeCellViewModelType {
    var inputs: CardSchemeCellViewModelInput { get }
    var outputs: CardSchemeCellViewModelOutput { get }
}

class CardSchemeCellViewModel: CardSchemeCellViewModelType, CardSchemeCellViewModelInput, CardSchemeCellViewModelOutput {
    
    //MARK: Properties
    
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)
    
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let descriptionSubject = BehaviorSubject<String>(value: "")
    private let buttonTitleSubject = BehaviorSubject<String>(value: "")
    private let cardImageSubject = BehaviorSubject<String>(value: "")
    
    var inputs: CardSchemeCellViewModelInput { self }
    var outputs: CardSchemeCellViewModelOutput { self }
    
    //MARK: Inputs
    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var value: Observable<String> { valueSubject.asObservable() }
    var selected: Observable<Bool> { selectedSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var description: Observable<String> { descriptionSubject.asObservable() }
    var buttonTitle: Observable<String> { buttonTitleSubject.asObservable() }
    var cardImage: Observable<String> { cardImageSubject.asObservable() }
    
    init(_ schemeModel: KYCCardsSchemeM) {
        
        titleSubject.onNext(schemeModel.cardTitle ?? "")
        descriptionSubject.onNext(schemeModel.cardDescription ?? "")
        buttonTitleSubject.onNext(schemeModel.cardButtonTitle ?? "")
        cardImageSubject.onNext(schemeModel.cardImage ?? "")
        
        
    }
    
}
