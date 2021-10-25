//
//  ReviewSelfieViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import Foundation
import RxSwift
import UIKit

protocol ReviewSelfieViewModelInputs {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol ReviewSelfieViewModelOutputs {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var image: Observable<UIImage> { get }
    var loading: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var languageStrings: Observable<ReviewSelfieViewModel.LanguageStrings> { get }
}

protocol ReviewSelfieViewModelType {
    var inputs: ReviewSelfieViewModelInputs { get }
    var outputs: ReviewSelfieViewModelOutputs { get }
}

class ReviewSelfieViewModel: ReviewSelfieViewModelType, ReviewSelfieViewModelInputs, ReviewSelfieViewModelOutputs {

    var inputs: ReviewSelfieViewModelInputs { return self }
    var outputs: ReviewSelfieViewModelOutputs { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var next: Observable<Void> { nextSuccessSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var image: Observable<UIImage> { imageSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var nextSuccessSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var loadingSubject = PublishSubject<Bool>()
    private var showErrorSubject = PublishSubject<String>()
    private var imageSubject: BehaviorSubject<UIImage>

    private var disposeBag = DisposeBag()
    private var kycRepository: KYCRepositoryType
    private var accountProvider: AccountProvider

    init(image: UIImage, kycRepository: KYCRepositoryType, accountProvider: AccountProvider) {

        self.kycRepository = kycRepository
        self.imageSubject = BehaviorSubject<UIImage>(value: image)
        self.accountProvider = accountProvider

        languageSetup()

        let uploadResult = nextSubject.withLatestFrom(imageSubject).withUnretained(self)
            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
            .map({ `self`, image in self.extracImageData(from: image) }).unwrap().withUnretained(self)
            .flatMapLatest { `self`, data in self.kycRepository.uploadSelfie(data) }
            .share()

        // uploadResult.elements()
        //   .map({ _ in () })
        //   .bind(to: nextSuccessSubject )
        //   .disposed(by: disposeBag)

        uploadResult.elements()
            .flatMap { [unowned self] _ in self.accountProvider.refreshAccount() }
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .bind(to: nextSuccessSubject)
            .disposed(by: disposeBag)

        uploadResult.errors()
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

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

//MARK: Helpers
fileprivate extension ReviewSelfieViewModel {
    func extracImageData(from image: UIImage) -> (data: Data, format: String)? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        return (data: imageData, format: "image/jpg")
    }
}
