//
//  SetpinIntroViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 10/11/2021.
//

import Foundation
import RxSwift

protocol SetpinIntroViewModelInputs {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol SetpinIntroViewModelOutputs {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<SetpinIntroViewModel.LanguageStrings> { get }
}

protocol SetpinIntroViewModelType {
    var inputs: SetpinIntroViewModelInputs { get }
    var outputs: SetpinIntroViewModelOutputs { get }
}

class SetpinIntroViewModel: SetpinIntroViewModelType, SetpinIntroViewModelInputs, SetpinIntroViewModelOutputs {

    var inputs: SetpinIntroViewModelInputs { return self }
    var outputs: SetpinIntroViewModelOutputs { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }

    // MARK: Subjects
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!

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

fileprivate extension SetpinIntroViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_setpinIntro_title".localized,
                                      subTitle: "screen_kyc_setpinintro_subtitle".localized,
                                      createPin: "screen_kyc_setpinintro_craete".localized,
                                      doItLater: "screen_kyc_setpinintro_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
