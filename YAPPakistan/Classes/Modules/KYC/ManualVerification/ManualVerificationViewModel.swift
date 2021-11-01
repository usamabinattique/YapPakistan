//
//  ManualVerificationViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation
import RxSwift

protocol ManualVerificationViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
}

protocol ManualVerificationViewModelOutputs {
    var back: Observable<Void> { get }
    var languageStrings: Observable<ManualVerificationViewModel.LanguageStrings> { get }
}

protocol ManualVerificationViewModelType {
    var inputs: ManualVerificationViewModelInputs { get }
    var outputs: ManualVerificationViewModelOutputs { get }
}

class ManualVerificationViewModel: ManualVerificationViewModelType, ManualVerificationViewModelInputs, ManualVerificationViewModelOutputs {

    var inputs: ManualVerificationViewModelInputs { return self }
    var outputs: ManualVerificationViewModelOutputs { return self }

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
        let goToDashboard: String
    }
}

fileprivate extension ManualVerificationViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_manualverification_title".localized,
                                      subTitle: "screen_kyc_manualverification_subtitle".localized,
                                      goToDashboard: "common_button_go_to_dashbaord".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
