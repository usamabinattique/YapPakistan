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
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var backSubject = PublishSubject<Void>()

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let topupNow: String
        let doItLater: String
    }
}

fileprivate extension SetPintSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_setpintsuccess_title".localized,
                                      subTitle: "screen_kyc_setpintsuccess_subtitle".localized,
                                      topupNow: "screen_kyc_setpintsuccess_topupnow".localized,
                                      doItLater: "screen_kyc_setpintsuccess_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}

