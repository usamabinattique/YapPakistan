//
//  SelfieGuidelineModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 13/10/2021.
//

import Foundation
import RxSwift

protocol SelfieGuidelineViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol SelfieGuidelineViewModelOutput {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<SelfieGuidelineViewModel.LanguageStrings> { get }
}

protocol SelfieGuidelineViewModelType {
    var inputs: SelfieGuidelineViewModelInput { get }
    var outputs: SelfieGuidelineViewModelOutput { get }
}

class SelfieGuidelineViewModel: SelfieGuidelineViewModelType, SelfieGuidelineViewModelInput, SelfieGuidelineViewModelOutput {

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { return languageStringsSubject.asObservable() }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    // MARK: Subjects
    var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()

    var inputs: SelfieGuidelineViewModelInput { return self }
    var outputs: SelfieGuidelineViewModelOutput { return self }

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let tips: String
        let action: String
    }
}

fileprivate extension SelfieGuidelineViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_take_selfie_title".localized,
                                      subTitle: "screen_kyc_take_selfie_subtitle".localized,
                                      tips: "screen_kyc_take_selfie_tip".localized,
                                      action: "screen_kyc_take_selfie_title".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
