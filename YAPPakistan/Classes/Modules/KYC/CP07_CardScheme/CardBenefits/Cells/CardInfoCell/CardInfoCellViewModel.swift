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
import RxDataSources

protocol CardInfoCellViewModelInput {
    var selectButtonObserver: AnyObserver<Bool> { get }
}

protocol CardInfoCellViewModelOutput {
    var selectButton: Observable<String> { get }
    var cardTitle: Observable<String> { get }
    var cardDescription: Observable<String> { get }
    var cardImageIcon: Observable<String> { get }
}

protocol CardInfoCellViewModelType {
    var inputs: CardInfoCellViewModelInput { get }
    var outputs: CardInfoCellViewModelOutput { get }
}

class CardInfoCellViewModel: CardInfoCellViewModelType, CardInfoCellViewModelInput, CardInfoCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    
    
    //MARK: Properties
    private var selectedSubject = PublishSubject<Bool>()
    private var selectButtonSubject = PublishSubject<String>()
    private var cardTitleSubject = BehaviorSubject<String>(value: "")
    private var cardDescriptionSubject = BehaviorSubject<String>(value: "")
    private var cardImageIconSubject = BehaviorSubject<String>(value: "")
    var reusableIdentifier: String { return CardInfoCell.defaultIdentifier }
    
    var inputs: CardInfoCellViewModelInput { self }
    var outputs: CardInfoCellViewModelOutput { self }
    
    private var schemeModel: KYCCardsSchemeM!
    
    //MARK: Inputs
    var selectButtonObserver: AnyObserver<Bool> { selectedSubject.asObserver() }
    
    //MARK: Outputs
    var selectButton: Observable<String> { selectButtonSubject.asObservable() }
    var cardTitle: Observable<String> { cardTitleSubject.asObservable() }
    var cardDescription: Observable<String> { cardDescriptionSubject.asObservable() }
    var cardImageIcon: Observable<String> { cardImageIconSubject.asObservable() }
    
    //MARK: Initializer
    init(_ schemeModel: KYCCardsSchemeM) {
        self.schemeModel = schemeModel
        
        cardTitleSubject.onNext(schemeModel.cardTitle ?? "")
        let fee = String(format: "%.2f", schemeModel.fee)
        cardDescriptionSubject.onNext(String(format: "screen_kyc_card_scheme_description_with_fee_detail".localized, "\(fee)"))//(schemeModel.cardDescription ?? "")
        cardImageIconSubject.onNext(schemeModel.scheme == .Mastercard ? "mastercard-icon" : schemeModel.scheme == .PayPak ? "paypak-icon" : "")
    }
    
}

