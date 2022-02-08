//
//  CardInfoCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 08/02/2022.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

protocol CardInfoCellViewModelInput {
    var selectButtonObserver: AnyObserver<Bool> { get }
}

protocol CardInfoCellViewModelOutput {
    var selectButton: Observable<String> { get }
    var benefitTitle: Observable<String> { get }
}

protocol CardInfoCellViewModelType {
    var inputs: CardInfoCellViewModelInput { get }
    var outputs: CardInfoCellViewModelOutput { get }
}

class CardInfoCellViewModel: CardInfoCellViewModelType, CardInfoCellViewModelInput, CardInfoCellViewModelOutput {
    
    
    //MARK: Properties
    private var selectedSubject = PublishSubject<Bool>()
    private var selectButtonSubject = PublishSubject<String>()
    private var benefitTitleSubject = BehaviorSubject<String>(value: "")
    
    var inputs: CardInfoCellViewModelInput { self }
    var outputs: CardInfoCellViewModelOutput { self }
    
    private var schemeModel: KYCCardsSchemeM!
    
    //MARK: Inputs
    var selectButtonObserver: AnyObserver<Bool> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var selectButton: Observable<String> { selectButtonSubject.asObservable() }
    var benefitTitle: Observable<String> { benefitTitleSubject.asObservable() }
    
    //MARK: Initializer
    init(_ schemeModel: KYCCardsSchemeM) {
        self.schemeModel = schemeModel
        
        benefitTitleSubject.onNext(schemeModel.cardTitle ?? "")
    }
    
}

