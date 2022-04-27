//
//  PersonalDetailsViewModel.swift
//  YAP
//
//  Created by Muhammad Hassan on 03/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import AVFoundation
import YAPCardScanner
import Foundation
import RxSwift
import YAPComponents


protocol PersonalDetailsViewModelInputs {
    var refreshObserver: AnyObserver<Void> { get }
    var editPhoneTapObserver: AnyObserver<Void> { get }
    var editEmailTapObserver: AnyObserver<Void> { get }
    var editAddressTapObserver: AnyObserver<Void> { get }
    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { get }
    var cardTapObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var addressUpdatedObserver: AnyObserver<Void> { get }
    var detectOCRObserver: AnyObserver<IdentityDocument> { get }
}

protocol PersonalDetailsViewModelOutputs {
    var title: Observable<String> { get }
    var fullName: Observable<String> { get }
    var phone: Observable<String> { get }
    var editPhoneTap: Observable<Void> { get }
    var email: Observable<String> { get }
    var editEmailTap: Observable<Void> { get }
    var address: Observable<String> { get }
    var editAddressTap: Observable<Void> { get }
    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { get }
    var isValidCnic: Observable<Bool> { get }
    var error: Observable<Error> { get }
    var back: Observable<Void> { get }
    var showBlockedOTPError: Observable<String>{ get }
    var showPermissionAlert: Observable<Void> { get }
    var scanCard: Observable<Void> { get }
}

protocol PersonalDetailsViewModelType {
    var inputs: PersonalDetailsViewModelInputs { get }
    var outputs: PersonalDetailsViewModelOutputs { get }
}

class PersonalDetailsViewModel: PersonalDetailsViewModelType, PersonalDetailsViewModelInputs, PersonalDetailsViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: PersonalDetailsViewModelInputs { return self }
    var outputs: PersonalDetailsViewModelOutputs { return self }
    var accountRepository : AccountRepositoryType
    var kycRepository: KYCRepositoryType
    
    private var customerDetail: CustomerPersonalDetailResponse!

    private let customer: Observable<Customer>
    private let refreshSubject = PublishSubject<Void>()
    private var emiratesIDStatusSubject = BehaviorSubject<UserProfileViewModel.EmiratesIDStatus>(value: .none)
    private let editPhoneTapSubject = PublishSubject<Void>()
    private let editEmailTapSubject = PublishSubject<Void>()
    private let editAddressTapSubject = PublishSubject<Void>()
    private let cardTapObserverSubject = PublishSubject<Void>()
    private let blockedOTPErrorMessageSubject = PublishSubject<String>()
    private let errorSubject = PublishSubject<Error>()
    private let backSubject = PublishSubject<Void>()
    private let addressUpdatedSubject = BehaviorSubject<Void>(value: ())
    private let isValidCnicSubject =  PublishSubject<Bool>()
    private var showPermissionAlertSubject = PublishSubject<Void>()
    private var cardSubject = PublishSubject<Void>()
    private var detectOCRSubject = PublishSubject<IdentityDocument>()
    private let documentsUploadSubject = PublishSubject<Void>()
    
    private let fullNameSubject = PublishSubject<String>()
    private let phoneSubject = PublishSubject<String>()
    private let emailSubject = PublishSubject<String>()
    private let addressSubject = PublishSubject<String>()


    // MARK: - Inputs
    var refreshObserver: AnyObserver<Void> { return refreshSubject.asObserver() }
    var editPhoneTapObserver: AnyObserver<Void> { return editPhoneTapSubject.asObserver() }
    var editEmailTapObserver: AnyObserver<Void> { return editEmailTapSubject.asObserver() }
    var editAddressTapObserver: AnyObserver<Void> { return editAddressTapSubject.asObserver() }
    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObserver() }
    var cardTapObserver: AnyObserver<Void> { return cardTapObserverSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var addressUpdatedObserver: AnyObserver<Void> { return addressUpdatedSubject.asObserver() }
    var detectOCRObserver: AnyObserver<IdentityDocument> { detectOCRSubject.asObserver() }

    // MARK: - Outputs
    var title: Observable<String> { return Observable.of( "screen_personal_details_display_text_personal_details_title".localized) }
    var fullName: Observable<String> { fullNameSubject.asObservable() }
    var phone: Observable<String> { phoneSubject.asObservable() }
    var editPhoneTap: Observable<Void> { return editPhoneTapSubject.asObservable() }
    var email: Observable<String> { emailSubject.asObservable() }
    var editEmailTap: Observable<Void> { return editEmailTapSubject.asObservable() }
    var address: Observable<String> { addressSubject.asObservable() }
    var editAddressTap: Observable<Void> { return editAddressTapSubject.asObservable() }
    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObservable() }
    var isValidCnic: Observable<Bool> { isValidCnicSubject.asObservable() }
    var error: Observable<Error> { return errorSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var showPermissionAlert: Observable<Void> { return showPermissionAlertSubject.asObservable() }
    var scanCard: Observable<Void> { return cardSubject.asObservable() }
    
    var showBlockedOTPError: Observable<String>{ blockedOTPErrorMessageSubject.asObservable() }
    // MARK: - Init
    init(_ customer: Observable<Customer>, accountRepository: AccountRepositoryType, kycRepository: KYCRepositoryType) {
        self.accountRepository = accountRepository
        self.kycRepository = kycRepository
        
        self.customer = customer
        fetchCustomer()

        cardTapObserverSubject.subscribe(onNext: { [weak self] in
            #warning("[UMAIR] - uncomment the following check to restrict card rescan for valid card")
//            if let isExpired = self?.customerDetail.cnicExpired, isExpired == true {
                self?.getCameraPermissions()
//            }
        }).disposed(by: disposeBag)
        
        initiateOCRApis()
    }
    
    
    func fetchCustomer() {
        
        let fetchPersonalDetail = refreshSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { self.accountRepository.fetchCustomerPersonalDetails() }
            .share()
        
        fetchPersonalDetail
            .subscribe(onNext:{ _ in YAPProgressHud.hideProgressHud() })
            .disposed(by: disposeBag)
        
        fetchPersonalDetail.errors()
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        fetchPersonalDetail.elements()
            .subscribe(onNext: { [unowned self] data in
                self.customerDetail = data
                self.fullNameSubject.onNext(data.fullName)
                self.phoneSubject.onNext(data.phoneNumber)
                self.emailSubject.onNext(data.email)
                self.addressSubject.onNext(data.address)
                self.isValidCnicSubject.onNext(data.cnicExpired)
            })
            .disposed(by: disposeBag)
    }
    
    func initiateOCRApis() {
        
        let ocrRequest = detectOCRSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { identityDocument -> Observable<Event<CNICOCR?>> in
                
                let frontImage = identityDocument.frontSide?.cropedImage
                guard let frontImageData = frontImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                let backImage = identityDocument.backSide?.cropedImage
                guard let backImageData = backImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                var documents = [(fileName: String, data: Data, format: String)]()
                documents.append((fileName: "files_f", data: frontImageData, format: "image/jpg"))
                documents.append((fileName: "files_b", data: backImageData, format: "image/jpg"))

                return self.kycRepository.detectCNICInfo(documents, progressObserver: nil)
            }
            .do(onNext: { [weak self] _ in
                self?.getCNICDocuments()
            })
            .share()

        ocrRequest.elements()
                .unwrap()
                .subscribe(onNext:{ [weak self] ocrObj in
                    //self?.cnicOCRSubject.onNext(ocrObj)
                    self?.documentsUploadSubject.onNext(())
                })
            //.unwrap()
            //.bind(to: cnicOCRSubject)
            .disposed(by: disposeBag)

        ocrRequest.errors()
                .subscribe(onNext: { [weak self] err in
                    YAPProgressHud.hideProgressHud()
                    print(err.localizedDescription)
                    self?.errorSubject.onNext(err)
                })
            .disposed(by: disposeBag)
    }
    
    func getCNICDocuments() {
        let request = documentsUploadSubject
            .flatMap { _ -> Observable<Event<Document?>> in
                self.kycRepository.fetchDocument(byType: DocumentType.cnic)
            }
            .share()

        request.errors()
                .subscribe(onNext: { [weak self] err in
                    YAPProgressHud.hideProgressHud()
                    print(err.localizedDescription)
                    self?.errorSubject.onNext(err)
                })
//            .bind(to: errorSubject)
            .disposed(by: disposeBag)

//        request.errors()
//            .map { _ in .notDetermined }
//            .bind(to: eidValidationSubject)
//            .disposed(by: disposeBag)

        request.elements()
//            .map {
//                if $0 != nil {
//                    return .valid
//                } else {
//                    return .notDetermined
//                }
//            }
            //.bind(to: eidValidationSubject)
            .subscribe(onNext:{ [weak self] _ in
                YAPProgressHud.hideProgressHud()
                print("doucment uploaded and get")
                self?.refreshSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
}

private extension PersonalDetailsViewModel {
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
