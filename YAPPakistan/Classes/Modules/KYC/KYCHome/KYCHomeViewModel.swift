//
//  KYCHomeViewModel.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import AVFoundation
import Foundation
import RxSwift
import YAPComponents

protocol KYCHomeViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var skipObserver: AnyObserver<Void> { get }
    var cardObserver: AnyObserver<Void> { get }
    var documentsUploadObserver: AnyObserver<Void> { get }
}

protocol KYCHomeViewModelOutput {
    var subHeadingText: Observable<String> { get }
    var skipButtonText: Observable<String> { get }
    var nextButtonEnabled: Observable<Bool> { get }
    var showPermissionAlert: Observable<Void> { get }
    var eidValidation: Observable<KYCDocumentView.Validation> { get }
    var next: Observable<Void> { get }
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

    var inputs: KYCHomeViewModelInput { return self }
    var outputs: KYCHomeViewModelOutput { return self }

    private var nextSubject = PublishSubject<Void>()
    private var skipSubject = PublishSubject<Void>()
    private var cardSubject = PublishSubject<Void>()
    private var cardObserverSubject = PublishSubject<Void>()
    private let documentsUploadSubject = PublishSubject<Void>()

    private var subHeadingSubject = BehaviorSubject<String>(value: "")
    private var skipTextSubject = BehaviorSubject<String>(value: "")
    private var nextButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var showPermissionAlertSubject = PublishSubject<Void>()
    private let eidValidationSubject = BehaviorSubject<KYCDocumentView.Validation>(value: .notDetermined)
    private let showErrorSubject = PublishSubject<String>()

    // MARK: Inputs

    var nextObserver: AnyObserver<Void> { return nextSubject.asObserver() }
    var skipObserver: AnyObserver<Void> { return skipSubject.asObserver() }
    var cardObserver: AnyObserver<Void> { return cardObserverSubject.asObserver() }
    var documentsUploadObserver: AnyObserver<Void> { return documentsUploadSubject.asObserver() }
    
    // MARK: Outputs

    var next: Observable<Void> { return nextSubject.asObservable() }
    var skip: Observable<Void> { return skipSubject.asObservable() }
    var scanCard: Observable<Void> { return cardSubject.asObservable() }
    var subHeadingText: Observable<String> { return subHeadingSubject.asObservable() }
    var skipButtonText: Observable<String> { return skipTextSubject.asObservable() }
    var nextButtonEnabled: Observable<Bool> { return nextButtonEnabledSubject.asObservable() }
    var showPermissionAlert: Observable<Void> { return showPermissionAlertSubject.asObservable() }
    var eidValidation: Observable<KYCDocumentView.Validation> { return eidValidationSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }

    // MARK: - Init

    init(accountProvider: AccountProvider, kycRepository: KYCRepository, initiatedFromDashboard: Bool) {
        let account = accountProvider.currentAccount.unwrap()
        account.map { String(format: "screen_kyc_home_display_text_sub_heading".localized, $0.customer.firstName) }
            .bind(to: subHeadingSubject).disposed(by: disposeBag)

        skipTextSubject.onNext(initiatedFromDashboard
                                ? "screen_kyc_home_button_skip".localized
                                : "screen_kyc_home_button_skip_no_dashboard".localized)
        nextButtonEnabledSubject.onNext(false)

        cardObserverSubject.subscribe(onNext: { [weak self] in
            self?.getCameraPermissions()
        }).disposed(by: disposeBag)

        eidValidationSubject.map { $0 == .valid }.bind(to: nextButtonEnabledSubject).disposed(by: disposeBag)

        let request = documentsUploadSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { _ -> Observable<Event<Document?>> in
                kycRepository.fetchDocument(byType: DocumentType.cnic)
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        request.errors().map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        request.errors()
            .map { _ in .notDetermined }
            .bind(to: eidValidationSubject)
            .disposed(by: disposeBag)

        request.elements()
            .map { $0?.isExpired ?? true ? .notDetermined : .valid }
            .bind(to: eidValidationSubject)
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
