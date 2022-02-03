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
}

protocol CardSchemeCellViewModelType {
    var inputs: CardSchemeCellViewModelInput { get }
    var outputs: CardSchemeCellViewModelOutput { get }
}

class CardSchemeCellViewModel: CardSchemeCellViewModelType, CardSchemeCellViewModelInput, CardSchemeCellViewModelOutput {
    
    //MARK: Properties
    
    private let valueSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)
    
    var inputs: CardSchemeCellViewModelInput { self }
    var outputs: CardSchemeCellViewModelOutput { self }
    
    //MARK: Inputs
    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var value: Observable<String> { valueSubject.asObservable() }
    var selected: Observable<Bool> { selectedSubject.asObservable() }
    
    init(value: String) {
        valueSubject.onNext(value)
    }
    
}
