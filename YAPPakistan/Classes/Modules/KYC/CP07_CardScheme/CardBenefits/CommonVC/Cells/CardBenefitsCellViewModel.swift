//
//  CardBenefitsCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

protocol CardBenefitsCellViewModelInput {
    var selectButtonObserver: AnyObserver<Bool> { get }
}

protocol CardBenefitsCellViewModelOutput {
    var selectButton: Observable<String> { get }
    var benefitTitle: Observable<String> { get }
}

protocol CardBenefitsCellViewModelType {
    var inputs: CardBenefitsCellViewModelInput { get }
    var outputs: CardBenefitsCellViewModelOutput { get }
}

class CardBenefitsCellViewModel: CardBenefitsCellViewModelType, CardBenefitsCellViewModelInput, CardBenefitsCellViewModelOutput {
    
    
    //MARK: Properties
    private var selectedSubject = PublishSubject<Bool>()
    private var selectButtonSubject = PublishSubject<String>()
    private var benefitTitleSubject = BehaviorSubject<String>(value: "")
    
    var inputs: CardBenefitsCellViewModelInput { self }
    var outputs: CardBenefitsCellViewModelOutput { self }
    
    private var schemeModel: KYCCardBenefitsM!
    
    //MARK: Inputs
    var selectButtonObserver: AnyObserver<Bool> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var selectButton: Observable<String> { selectButtonSubject.asObservable() }
    var benefitTitle: Observable<String> { benefitTitleSubject.asObservable() }
    
    //MARK: Initializer
    init(_ schemeModel: KYCCardBenefitsM) {
        self.schemeModel = schemeModel
        
        benefitTitleSubject.onNext(schemeModel.description)
    }
    
}
