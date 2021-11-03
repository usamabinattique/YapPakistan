//
//  CardOnItsWayViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation
import RxSwift

protocol CardOnItsWayViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol CardOnItsWayViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<CardOnItsWayViewModel.LanguageStrings> { get }
}

protocol CardOnItsWayViewModelType {
    var inputs: CardOnItsWayViewModelInputs { get }
    var outputs: CardOnItsWayViewModelOutputs { get }
}

class CardOnItsWayViewModel: CardOnItsWayViewModelType, CardOnItsWayViewModelInputs, CardOnItsWayViewModelOutputs {

    var inputs: CardOnItsWayViewModelInputs { return self }
    var outputs: CardOnItsWayViewModelOutputs { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var backSubject = PublishSubject<Void>()

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let cinc: String
        let goToDashboard: String
    }
}

fileprivate extension CardOnItsWayViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_cardonway_title".localized,
                                      subTitle: "screen_kyc_cardonway_subtitle".localized,
                                      cinc: "common_display_text_cnic".localized,
                                      goToDashboard: "common_button_go_to_dashbaord".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
