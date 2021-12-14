//
//  PinChangeSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import Foundation
import RxSwift

protocol PinChangeSuccessViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol PinChangeSuccessViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<PinChangeSuccessViewModel.LanguageStrings> { get }
}

protocol PinChangeSuccessViewModelType {
    var inputs: PinChangeSuccessViewModelInputs { get }
    var outputs: PinChangeSuccessViewModelOutputs { get }
}

class PinChangeSuccessViewModel: PinChangeSuccessViewModelType, PinChangeSuccessViewModelInputs, PinChangeSuccessViewModelOutputs {

    var inputs: PinChangeSuccessViewModelInputs { return self }
    var outputs: PinChangeSuccessViewModelOutputs { return self }

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

fileprivate extension PinChangeSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "Great, you've successfully updated your PIN!",
                                      subTitle: "Remember this PIN as you'll need it for all your transactions, and make sure you don't share it with anyone",
                                      topupNow: "screen_kyc_PinChangeSuccess_topupnow".localized,
                                      doItLater: "screen_kyc_PinChangeSuccess_doitlater".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}


