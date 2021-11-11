//
//  SetCardPinViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import Foundation
import RxSwift

protocol SetCardPinViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol SetCardPinViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<SetCardPinViewModel.LanguageStrings> { get }
}

protocol SetCardPinViewModelType {
    var inputs: SetCardPinViewModelInputs { get }
    var outputs: SetCardPinViewModelOutputs { get }
}

class SetCardPinViewModel: SetCardPinViewModelType, SetCardPinViewModelInputs, SetCardPinViewModelOutputs {

    var inputs: SetCardPinViewModelInputs { return self }
    var outputs: SetCardPinViewModelOutputs { return self }

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
        let createPin: String
        let doItLater: String
    }
}

fileprivate extension SetCardPinViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_SetCardPin_title".localized,
                                      subTitle: "screen_kyc_SetCardPin_subtitle".localized,
                                      createPin: "screen_kyc_SetCardPin_craete".localized,
                                      doItLater: "screen_kyc_SetCardPin_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}

