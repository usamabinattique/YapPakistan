//
//  KYCReviewDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 30/09/2021.
//

import YAPCardScanner
import Foundation
import RxSwift
import YAPComponents
import Contacts

protocol KYCReviewDetailsViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
}

protocol KYCReviewDetailsViewModelOutput {
    var cnicNumber: Observable<String> { get }
    var cnicFields: Observable<[KYCReviewFieldViewModel]> { get }
    var showError: Observable<String> { get }
    var next: Observable<Void> { get }
    var cnicBlockCase: Observable<CNICBlockCase> { get }
}

protocol KYCReviewDetailsViewModelType {
    var inputs: KYCReviewDetailsViewModelInput { get }
    var outputs: KYCReviewDetailsViewModelOutput { get }
}

class KYCReviewDetailsViewModel: KYCReviewDetailsViewModelInput, KYCReviewDetailsViewModelOutput, KYCReviewDetailsViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let cnicNumberSubject = BehaviorSubject<String>(value: "")
    private var cnicFieldsSubject = BehaviorSubject<[KYCReviewFieldViewModel]>(value: [])
    private let showErrorSubject = PublishSubject<String>()
    private let nameValueSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let fatherNameValueSubject = ReplaySubject<String>.create(bufferSize: 1)

    private var cnicInfo: CNICInfo
    private var cnicOCR: CNICOCR
    
    private var nextSubject = PublishSubject<Void>()
    private var successSubject = PublishSubject<Void>()
    private var cnicBlockCaseSubject  = PublishSubject<CNICBlockCase>()

    var inputs: KYCReviewDetailsViewModelInput { return self }
    var outputs: KYCReviewDetailsViewModelOutput { return self }

    // MARK: Inputs

    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }

    // MARK: Outputs
    var cnicBlockCase: Observable<CNICBlockCase> { cnicBlockCaseSubject.asObservable() }
    var cnicNumber: Observable<String> { cnicNumberSubject.asObservable() }
    var cnicFields: Observable<[KYCReviewFieldViewModel]> { cnicFieldsSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var next: Observable<Void> { successSubject.asObservable() }

    // MARK: Initialization

    init(accountProvider: AccountProvider,
         kycRepository: KYCRepository,
         identityDocument: IdentityDocument,
         cnicOCR: CNICOCR,
         cnicInfo: CNICInfo) {
        
        self.cnicInfo = cnicInfo
        self.cnicOCR = cnicOCR
        
        notifyFields()
        bindSaveRequest(identityDocument: identityDocument, cnicNumber: cnicOCR.cnicNumber, kycRepository: kycRepository, accountProvider: accountProvider)
    }

    private func notifyFields() {
        cnicNumberSubject.onNext(self.cnicOCR.cnicNumber)
        cnicFieldsSubject.onNext([
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_full_name".localized,
                                    value: self.cnicInfo.name, valueChanged: nameValueSubject.asObserver(), isEditable: true),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_father_spouse_name".localized,
                                    value: self.cnicOCR.guardianName ?? "", valueChanged: fatherNameValueSubject.asObserver(), isEditable: true),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_gender".localized,
                                    value: self.cnicInfo.gender),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_dob".localized,
                                    value: parseDate(self.cnicInfo.dob)),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_issue_date".localized,
                                    value: parseDate(self.cnicInfo.issueDate)),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_expiry_date".localized,
                                    value: parseDate(self.cnicInfo.expiryDate)),
            KYCReviewFieldViewModel(heading: "screen_kyc_review_details_residential_address".localized,
                                    value: self.cnicInfo.residentialAddress)
        ])
        
        nameValueSubject
            .subscribe(onNext: { value in
                if value.length != 0 {
                    self.cnicInfo.name = value
                }
            }).disposed(by: disposeBag)
        fatherNameValueSubject
            .subscribe(onNext: { value in
                if value.length != 0 {
                    self.cnicInfo.fatherSpouseName = value
                }
            }).disposed(by: disposeBag)
    }

    private func bindSaveRequest(identityDocument: IdentityDocument,
                                 cnicNumber: String,
                                 kycRepository: KYCRepository,
                                 accountProvider: AccountProvider) {
        
//        nextSubject.subscribe(onNext: { [weak self] _ in
//            guard let self = self else { return }
//            self.cnicBlockCaseSubject.onNext(.cnicExpiredOnScane)
//        }).disposed(by: disposeBag)
        
        let saveRequest = nextSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { [weak self] _ -> Observable<Event<String?>> in
                guard let self = self,
                      let documents = self.extractDocuments(from: identityDocument) else {
                    return .empty()
                }

                let documentType = "CNIC"
//                let identityNo = cnicNumber.replace(string: "-", replacement: "")
                //!!!: Random Cnic for testing
                let identityNo = self.getRandomNumber()
                let nationality = "PAK"
                let fullName = self.cnicInfo.name
                let fatherName = self.cnicOCR.guardianName
                let gender = self.cnicInfo.gender
                let dob = self.cnicInfo.dob
                let dateIssue = self.cnicInfo.issueDate
                let dateExpiry = self.cnicInfo.expiryDate

                return kycRepository.saveDocuments(documents, documentType: documentType,
                                                   identityNo: identityNo, nationality: nationality,
                                                   fullName: fullName, fatherName: fatherName ?? "", gender: "\(gender.charactersArray[0])", dob: dob,
                                                   dateIssue: dateIssue, dateExpiry: dateExpiry)
            }
            .share()

        saveRequest.elements().subscribe(onNext: { [unowned self] response in

            print(response)

            self.cnicBlockCaseSubject.onNext(.underAge)

        }).disposed(by: disposeBag)

        saveRequest.errors().subscribe(onNext: { [unowned self] error in
            print(error.localizedDescription)
        }).disposed(by: disposeBag)

        let refreshAccountRequest = saveRequest.elements()
            .flatMap { _ in
                accountProvider.refreshAccount()
            }
            .share()

        refreshAccountRequest
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .bind(to: successSubject)
            .disposed(by: disposeBag)

        saveRequest.errors()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }

    private func parseDate(_ dateString: String) -> String {
        let serverFormatter = DateFormatter.serverReadableDateFromatter
        let appFormatter = DateFormatter.appReadableDateFormatter

        guard let date = serverFormatter.date(from: dateString) else {
            return ""
        }

        return appFormatter.string(from: date)
    }

    private func extractDocuments(from identityDocument: IdentityDocument) -> [(data: Data, format: String)]? {
        guard let frontImage = identityDocument.frontSide?.cropedImage,
              let frontData = frontImage.jpegData(compressionQuality: 1.0),
              let backImage = identityDocument.backSide?.cropedImage,
              let backData = backImage.jpegData(compressionQuality: 1.0) else {
            return nil
              }
        
        return [(data: frontData, format: "image/jpg"), (data: backData, format: "image/jpg")]
    }
    
    private func getRandomNumber() -> String {
        var prefix = "352023333"
        let randomInt1 = Int.random(in: 1000 ... 5000)
        prefix += "\(randomInt1)"
        return prefix
    }
}
