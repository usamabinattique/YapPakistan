//
//  AccountOpenSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import Foundation
import RxSwift

protocol AccountOpenSuccessViewModelInputs {
    var gotoDashboardObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol AccountOpenSuccessViewModelOutputs {
    var back: Observable<Void> { get }
    var gotoDashboard: Observable<Void> { get }
    var languageStrings: Observable<AccountOpenSuccessViewModel.LanguageStrings> { get }
}

protocol AccountOpenSuccessViewModelType {
    var inputs: AccountOpenSuccessViewModelInputs { get }
    var outputs: AccountOpenSuccessViewModelOutputs { get }
}

class AccountOpenSuccessViewModel: AccountOpenSuccessViewModelType, AccountOpenSuccessViewModelInputs, AccountOpenSuccessViewModelOutputs {

    var inputs: AccountOpenSuccessViewModelInputs { return self }
    var outputs: AccountOpenSuccessViewModelOutputs { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var gotoDashboardObserver: AnyObserver<Void> { return gotoDashboardSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var gotoDashboard: Observable<Void> { return gotoDashboardSubject.asObservable() }
    
    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var backSubject = PublishSubject<Void>()
    private var gotoDashboardSubject = PublishSubject<Void>()

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

fileprivate extension AccountOpenSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_success_title".localized,
                                      subTitle: "screen_kyc_cardonway_subtitle".localized,
                                      cinc: "common_display_text_cnic".localized,
                                      goToDashboard: "common_button_go_to_dashbaord".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
