//
//  ReviewSelfieViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import Foundation
import RxSwift

protocol ReviewSelfieViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol ReviewSelfieViewModelOutput {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<ReviewSelfieViewModel.LanguageStrings> { get }
}

protocol ReviewSelfieViewModelType {
    var inputs: ReviewSelfieViewModelInput { get }
    var outputs: ReviewSelfieViewModelOutput { get }
}

class ReviewSelfieViewModel: ReviewSelfieViewModelType, ReviewSelfieViewModelInput, ReviewSelfieViewModelOutput {

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()

    var inputs: ReviewSelfieViewModelInput { return self }
    var outputs: ReviewSelfieViewModelOutput { return self }

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let yesItsMe: String
        let retakeSelfie: String
    }
}

fileprivate extension ReviewSelfieViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_review_selfie_title".localized,
                                      subTitle: "screen_kyc_review_selfie_subtitle".localized,
                                      yesItsMe: "screen_kyc_review_selfie_yesitsme".localized,
                                      retakeSelfie: "screen_kyc_review_selfie_retake".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
