//
//  File15.swift
//  YAPPakistan
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation
import RxSwift

protocol PinForgotSuccessViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol PinForgotSuccessViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<PinForgotSuccessViewModel.LanguageStrings> { get }
}

protocol PinForgotSuccessViewModelType {
    var inputs: PinForgotSuccessViewModelInputs { get }
    var outputs: PinForgotSuccessViewModelOutputs { get }
}

class PinForgotSuccessViewModel: PinForgotSuccessViewModelType, PinForgotSuccessViewModelInputs, PinForgotSuccessViewModelOutputs {

    var inputs: PinForgotSuccessViewModelInputs { return self }
    var outputs: PinForgotSuccessViewModelOutputs { return self }

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

fileprivate extension PinForgotSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_PinChangeSuccess_title".localized,
                                      subTitle: "screen_kyc_PinChangeSuccess_subtitle".localized,
                                      topupNow: "screen_kyc_PinChangeSuccess_topupnow".localized,
                                      doItLater: "screen_kyc_PinChangeSuccess_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}



