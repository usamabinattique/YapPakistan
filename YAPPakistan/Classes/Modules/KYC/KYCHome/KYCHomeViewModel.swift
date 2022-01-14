//
//  KYCHomeViewModel.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import AVFoundation
import CardScanner
import Foundation
import RxSwift
import YAPComponents

 //enum AccountStatus:String, Hashable {
 //   case questions, SELFIE_PENDING, other
 //}

protocol KYCHomeViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var reloadAndNextObserver: AnyObserver<Void> { get }
    var skipObserver: AnyObserver<Void> { get }
    var cardObserver: AnyObserver<Void> { get }
    var documentsUploadObserver: AnyObserver<Void> { get }
    var detectOCRObserver: AnyObserver<IdentityDocument> { get }
}

protocol KYCHomeViewModelOutput {
    var subHeadingText: Observable<String> { get }
    var skipButtonText: Observable<String> { get }
    var nextButtonEnabled: Observable<Bool> { get }
    var showPermissionAlert: Observable<Void> { get }
    var eidValidation: Observable<KYCDocumentView.Validation> { get }
    var cnicOCR: Observable<CNICOCR> { get }
    var next: Observable<AccountStatus> { get }
    var skip: Observable<Void> { get }
    var scanCard: Observable<Void> { get }
    var showError: Observable<String> { get }
}

protocol KYCHomeViewModelType {
    var inputs: KYCHomeViewModelInput { get }
    var outputs: KYCHomeViewModelOutput { get }
}

class KYCHomeViewModel: KYCHomeViewModelType, KYCHomeViewModelInput, KYCHomeViewModelOutput {
    
    // MARK: Properties

    let disposeBag = DisposeBag()

    let accountProvider: AccountProvider!
    //let account: Observable<Account>!

    var inputs: KYCHomeViewModelInput { return self }
    var outputs: KYCHomeViewModelOutput { return self }

    private var nextSubject = PublishSubject<Void>()
    private var reloadAndNextSubject = PublishSubject<Void>()
    private var nextCheckPointSubject = BehaviorSubject<AccountStatus?>(value: nil)
    private var skipSubject = PublishSubject<Void>()
    private var cardSubject = PublishSubject<Void>()
    private var cardObserverSubject = PublishSubject<Void>()
    private let documentsUploadSubject = PublishSubject<Void>()
    private let detectOCRSubject = PublishSubject<IdentityDocument>()

    private var subHeadingSubject = BehaviorSubject<String>(value: "")
    private var skipTextSubject = BehaviorSubject<String>(value: "")
    private var nextButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var showPermissionAlertSubject = PublishSubject<Void>()
    private let eidValidationSubject = BehaviorSubject<KYCDocumentView.Validation>(value: .notDetermined)
    private let cnicOCRSubject = PublishSubject<CNICOCR>()
    private let showErrorSubject = PublishSubject<String>()

    // MARK: Inputs

    var nextObserver: AnyObserver<Void> { return nextSubject.asObserver() }
    var reloadAndNextObserver: AnyObserver<Void> { reloadAndNextSubject.asObserver() }
    var skipObserver: AnyObserver<Void> { return skipSubject.asObserver() }
    var cardObserver: AnyObserver<Void> { return cardObserverSubject.asObserver() }
    var documentsUploadObserver: AnyObserver<Void> { return documentsUploadSubject.asObserver() }
    var detectOCRObserver: AnyObserver<IdentityDocument> { return detectOCRSubject.asObserver() }
    
    // MARK: Outputs

    var next: Observable<AccountStatus> { return nextCheckPointSubject.unwrap().asObservable() }
    var skip: Observable<Void> { return skipSubject.asObservable() }
    var scanCard: Observable<Void> { return cardSubject.asObservable() }
    var subHeadingText: Observable<String> { return subHeadingSubject.asObservable() }
    var skipButtonText: Observable<String> { return skipTextSubject.asObservable() }
    var nextButtonEnabled: Observable<Bool> { return nextButtonEnabledSubject.asObservable() }
    var showPermissionAlert: Observable<Void> { return showPermissionAlertSubject.asObservable() }
    var eidValidation: Observable<KYCDocumentView.Validation> { return eidValidationSubject.asObservable() }
    var cnicOCR: Observable<CNICOCR> { return cnicOCRSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }

    // MARK: - Init

    init(accountProvider: AccountProvider, kycRepository: KYCRepository) {

        self.accountProvider = accountProvider

        reloadAndNextSubject.withUnretained(self)
            .flatMap { `self`, _ in self.accountProvider.refreshAccount() }
            .withLatestFrom(self.accountProvider.currentAccount)
            .map({ $0?.accountStatus })
            .bind(to: nextCheckPointSubject)
            .disposed(by: disposeBag)

        let account = self.accountProvider.currentAccount.unwrap()

        account.map { String(format: "screen_kyc_home_display_text_sub_heading".localized, $0.customer.firstName) }
            .bind(to: subHeadingSubject).disposed(by: disposeBag)

        skipTextSubject.onNext("screen_kyc_home_button_skip_no_dashboard".localized)
        nextButtonEnabledSubject.onNext(false)

        cardObserverSubject.subscribe(onNext: { [weak self] in
            self?.getCameraPermissions()
        }).disposed(by: disposeBag)

        eidValidationSubject.map {
            $0 == .valid
        }.bind(to: nextButtonEnabledSubject).disposed(by: disposeBag)

        let request = documentsUploadSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { _ -> Observable<Event<Document?>> in
                kycRepository.fetchDocument(byType: DocumentType.cnic)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        request.errors().map {
            $0.localizedDescription
        }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        request.errors()
            .map { _ in .notDetermined }
            .bind(to: eidValidationSubject)
            .disposed(by: disposeBag)

        request.elements()
            .map {
                $0?.isExpired ?? true ? .notDetermined : .valid
            }
            .bind(to: eidValidationSubject)
            .disposed(by: disposeBag)

        nextSubject.withLatestFrom(self.accountProvider.currentAccount)
            .unwrap().map({
                $0.accountStatus
            })
            .bind(to: nextCheckPointSubject).disposed(by: disposeBag)

        let ocrRequest = detectOCRSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { identityDocument -> Observable<Event<CNICOCR?>> in
                let frontImage = identityDocument.frontSide?.cropedImage
                guard let imageData = frontImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }

                return kycRepository.detectCNICInfo([(imageData, "image/jpg")])
            }
            .do(onNext: { [weak self] _ in
                YAPProgressHud.hideProgressHud()
                self?.documentsUploadObserver.onNext(())
            })
            .share()

        ocrRequest.elements()
            .unwrap()
            .bind(to: cnicOCRSubject)
            .disposed(by: disposeBag)

        ocrRequest.errors()
            .map {
                $0.localizedDescription
            }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
}

private extension KYCHomeViewModel {
    func getCameraPermissions() {
        let permissiontStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if permissiontStatus == .denied || permissiontStatus == .restricted {
            self.showPermissionAlertSubject.onNext(())
            return
        }
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            cardSubject.onNext(())
            return
        }
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [unowned self] (granted: Bool) in
            if granted {
                DispatchQueue.main.async { [weak self] in
                    self?.cardSubject.onNext(())
                }
            }
        })
    }
}
