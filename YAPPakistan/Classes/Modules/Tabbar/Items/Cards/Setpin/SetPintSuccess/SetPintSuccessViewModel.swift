//
//  SetPintSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import Foundation
import RxSwift

protocol SetPintSuccessViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol SetPintSuccessViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<SetPintSuccessViewModel.LanguageStrings> { get }
}

protocol SetPintSuccessViewModelType {
    var inputs: SetPintSuccessViewModelInputs { get }
    var outputs: SetPintSuccessViewModelOutputs { get }
}

class SetPintSuccessViewModel: SetPintSuccessViewModelType, SetPintSuccessViewModelInputs, SetPintSuccessViewModelOutputs {

    var inputs: SetPintSuccessViewModelInputs { return self }
    var outputs: SetPintSuccessViewModelOutputs { return self }

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

fileprivate extension SetPintSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_SetPintSuccess_title".localized,
                                      subTitle: "screen_kyc_SetPintSuccess_subtitle".localized,
                                      createPin: "screen_kyc_SetPintSuccess_craete".localized,
                                      doItLater: "screen_kyc_SetPintSuccess_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}

