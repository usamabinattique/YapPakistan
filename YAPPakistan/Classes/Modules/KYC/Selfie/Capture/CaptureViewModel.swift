//
//  CaptureViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import Foundation
import RxSwift

protocol CaptureViewModelInputs {
    var nextObserver: AnyObserver<UIImage?> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol CaptureViewModelOutputs {
    var next: Observable<UIImage?> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<CaptureViewModel.LanguageStrings> { get }
}

protocol CaptureViewModelType {
    var inputs: CaptureViewModelInputs { get }
    var outputs: CaptureViewModelOutputs { get }
}

class CaptureViewModel: CaptureViewModelType, CaptureViewModelInputs, CaptureViewModelOutputs {

    var inputs: CaptureViewModelInputs { return self }
    var outputs: CaptureViewModelOutputs { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<UIImage?> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var next: Observable<UIImage?> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<UIImage?>()
    private var backSubject = PublishSubject<Void>()

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


fileprivate extension CaptureViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_review_selfie_title".localized,
                                      subTitle: "screen_kyc_review_selfie_subtitle".localized,
                                      yesItsMe: "screen_kyc_review_selfie_yesitsme".localized,
                                      retakeSelfie: "screen_kyc_review_selfie_retake".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
