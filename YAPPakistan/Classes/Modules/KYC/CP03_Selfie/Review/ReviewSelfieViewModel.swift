//
//  ReviewSelfieViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import Foundation
import RxSwift
import UIKit
import YAPComponents

protocol ReviewSelfieViewModelInputs {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol ReviewSelfieViewModelOutputs {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var selfieComplete: Observable <Void> { get }
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
    var selfieComplete: Observable <Void> { selfieCompleteSubject.asObservable() }
    
    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var nextSuccessSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var loadingSubject = PublishSubject<Bool>()
    private var showErrorSubject = PublishSubject<String>()
    private var imageSubject: BehaviorSubject<UIImage>
    private var selfieCompleteSubject = PublishSubject<Void>()
    
    private var disposeBag = DisposeBag()
    private var kycRepository: KYCRepositoryType
    private var accountProvider: AccountProvider
    private var isSelfieMatched : Bool = false
    
    init(image: UIImage, kycRepository: KYCRepositoryType, accountProvider: AccountProvider) {
        
        self.kycRepository = kycRepository
        self.imageSubject = BehaviorSubject<UIImage>(value: image)
        self.accountProvider = accountProvider
        
        languageSetup()
        
//        let uploadResult = nextSubject.withLatestFrom(imageSubject).withUnretained(self)
//            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
//                .map({ `self`, image in self.extracImageData(from: image) }).unwrap().withUnretained(self)
//                .flatMapLatest { `self`, data in self.kycRepository.uploadSelfieComparison(data, isCompared: true)
//
//                }
//                .share()
//
//        uploadResult.elements()
//            .flatMap { [unowned self] _ in self.accountProvider.refreshAccount() }
//            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
//                .bind(to: nextSuccessSubject)
//                .disposed(by: disposeBag)
//
//                uploadResult.errors()
//                .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
//                    .map { $0.localizedDescription }
//                    .bind(to: showErrorSubject)
//                    .disposed(by: disposeBag)
        
        self.nextSubject.subscribe(onNext: { _ in
            
            self.verifyPictureOCR()
            
        }).disposed(by: disposeBag)
        
        //generateIBAN()
    }
    
    func verifyPictureOCR() {
        self.image.subscribe(onNext: { [weak self] image in
            guard let self = self else { return }
            
            let compressedImage = image.jpegData(compressionQuality: 0.3)!
            do {
                try UploadingImageValiadtor(data: compressedImage).validate()
            } catch let err {
                print("image validation error \(err.localizedDescription)")
            }
            
            
            YAPProgressHud.showProgressHud()
            
            let veriyFaceReq = self.kycRepository.verifyFaceOCR(compressedImage, fileName: "file_selfie", mimeType: "image/jpg").share()
            
            
            // Selfie Match Success
            veriyFaceReq.elements().subscribe(onNext: { [weak self] response in
                guard let _ = self else { return }
                print(response)
                YAPProgressHud.hideProgressHud()
                self?.isSelfieMatched = true
                self?.uploadSelfie(data: compressedImage)
                
            }).disposed(by: self.disposeBag)
            
            // Selfie did not match
            veriyFaceReq.errors().subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                YAPProgressHud.hideProgressHud()
                self.isSelfieMatched = false
                self.uploadSelfie(data: compressedImage)
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func uploadSelfie(data: Data) {
        let uploadSelfieReq = self.kycRepository.uploadSelfie((data, "image/jpg")).share()
        YAPProgressHud.showProgressHud()
        uploadSelfieReq.elements().subscribe(onNext: { [weak self] response in
            print(response)
            YAPProgressHud.hideProgressHud()
            guard let self = self else { return }
            self.generateIBAN(isSelfieMatched: self.isSelfieMatched)
            
           
            
        }).disposed(by: self.disposeBag)
        
        uploadSelfieReq.errors().subscribe(onNext: { [weak self] error in
            print(error.localizedDescription)
            YAPProgressHud.hideProgressHud()
        }).disposed(by: self.disposeBag)
    }
    
    func generateIBAN(isSelfieMatched: Bool) {
        YAPProgressHud.showProgressHud()
        let req = self.kycRepository.generateIBAN(isSelfieMatched: isSelfieMatched).share()
        
        req.elements().subscribe(onNext: { [weak self] result in
            YAPProgressHud.hideProgressHud()
            guard let _ = self else { return }
            print(result)
            self?.selfieCompleteSubject.onNext(())
        }).disposed(by: disposeBag)
        
        req.errors().subscribe(onNext: { [weak self] error in
            YAPProgressHud.hideProgressHud()
            guard let _  = self else { return }
            print(error.localizedDescription)
            self?.showErrorSubject.onNext(error.localizedDescription)
            //self?.selfieCompleteSubject.onNext(())
        }).disposed(by: disposeBag)
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

// MARK: Helpers
fileprivate extension ReviewSelfieViewModel {
    func extracImageData(from image: UIImage) -> (data: Data, format: String)? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        return (data: imageData, format: "image/jpg")
    }
}
