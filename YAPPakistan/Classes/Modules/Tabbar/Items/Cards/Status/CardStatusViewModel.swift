//
//  CardStatusViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import RxSwift

enum CardStatus: Int {
    case completeVerification, ordering, building, shipping
}

protocol CardStatusViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
}

protocol CardStatusViewModelOutputs {
    var back: Observable<Void> { get }
    var statusString: Observable<String> { get }
    var actionString: Observable<String> { get }
    var cardStatus: Observable<CardStatus> { get }
    var languageStrings: Observable<CardStatusViewModel.LanguageStrings> { get }
}

protocol CardStatusViewModelType {
    var inputs: CardStatusViewModelInputs { get }
    var outputs: CardStatusViewModelOutputs { get }
}

class CardStatusViewModel: CardStatusViewModelType, CardStatusViewModelInputs, CardStatusViewModelOutputs {

    var inputs: CardStatusViewModelInputs { return self }
    var outputs: CardStatusViewModelOutputs { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var statusString: Observable<String> { statusStringSubject.asObservable() }
    var actionString: Observable<String> { actionStringSubject.asObservable() }
    var cardStatus: Observable<CardStatus> { cardStatusSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }

    // MARK: Subjects
    private var nextSubject = PublishSubject<Void>()
    private var statusStringSubject = PublishSubject<String>()
    private var cardStatusSubject = PublishSubject<CardStatus>()
    private var actionStringSubject = PublishSubject<String>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var backSubject = PublishSubject<Void>()

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let goToDashboard: String
    }
}

fileprivate extension CardStatusViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_cardStatus_title".localized,
                                      subTitle: "screen_kyc_cardStatus_subtitle".localized,
                                      goToDashboard: "common_button_go_to_dashbaord".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
