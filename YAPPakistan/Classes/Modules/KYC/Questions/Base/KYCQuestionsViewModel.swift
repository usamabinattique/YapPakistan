//
//  KYCQuestionsViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 06/10/2021.
//

import CardScanner
import Foundation
import RxSwift
import YAPComponents

struct KYCStrings {
    var title: String
    var subHeading: String
    var next: String
}

protocol KYCQuestionViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
}

protocol KYCQuestionViewModelOutput {
    var optionViewModels: Observable<[KYCQuestionCellViewModel]> { get }
    var showError: Observable<String> { get }
    var isNextEnable: Observable<Bool> { get }
    var next: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var strings: Observable<KYCStrings> { get }
}

protocol KYCQuestionViewModelType {
    var inputs: KYCQuestionViewModelInput { get }
    var outputs: KYCQuestionViewModelOutput { get }
}

class KYCQuestionViewModel: KYCQuestionViewModelInput, KYCQuestionViewModelOutput, KYCQuestionViewModelType {

    var optionViewModelsSubject = BehaviorSubject<[KYCQuestionCellViewModel]>(value: [])
    let showErrorSubject = PublishSubject<String>()
    var isNextEnableSubject = BehaviorSubject<Bool>(value: false)
    var nextSubject = PublishSubject<Void>()
    var successSubject = PublishSubject<Void>()
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var stringsSubject: BehaviorSubject<KYCStrings>

    var inputs: KYCQuestionViewModelInput { return self }
    var outputs: KYCQuestionViewModelOutput { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }

    // MARK: Outputs
    var optionViewModels: Observable<[KYCQuestionCellViewModel]> { optionViewModelsSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var isNextEnable: Observable<Bool> { isNextEnableSubject.asObservable() }
    var next: Observable<Void> { successSubject.asObservable() } // FIXME should be successSubject
    var loader: Observable<Bool> { loaderSubject.asObserver() }
    var strings: Observable<KYCStrings> { stringsSubject.asObservable() }

    // MARK: Properties
    var accountProvider: AccountProvider!
    let disposeBag = DisposeBag()
    private let cellViewModel:Observable<[KYCQuestionCellViewModel]>

    // MARK: Initialization

    init(accountProvider: AccountProvider,
         cellViewModel: Observable<[KYCQuestionCellViewModel]>,
         strings: KYCStrings) {

        self.accountProvider = accountProvider
        self.stringsSubject = BehaviorSubject<KYCStrings>(value: strings)
        self.cellViewModel = cellViewModel.share()

        self.cellViewModel
            .bind(to: optionViewModelsSubject)
            .disposed(by: disposeBag)

        self.cellViewModel.subscribe(onNext: { vms in
            let oss =  vms.map({ $0.outputs.selected })

            oss.forEach { [unowned self] isSelected in
                isSelected.filter({ $0 })
                    .distinctUntilChanged()
                    .bind(to: self.isNextEnableSubject).disposed(by: self.disposeBag)
            }

        }).disposed(by: disposeBag)
        
    }

    private func bindSaveRequest(identityDocument: IdentityDocument,
                                 cnicNumber: String,
                                 cnicInfo: CNICInfo,
                                 kycRepository: KYCRepository,
                                 accountProvider: AccountProvider) {
        let saveRequest = nextSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { [weak self] _ -> Observable<Event<String?>> in
                guard let self = self,
                      let documents = self.extractDocuments(from: identityDocument) else {
                    return .empty()
                }

                let documentType = "CNIC"
                let identityNo = cnicNumber.replace(string: "-", replacement: "")
                let nationality = "PAK"
                let fullName = cnicInfo.name
                let gender = cnicInfo.gender
                let dob = cnicInfo.dob
                let dateIssue = cnicInfo.issueDate
                let dateExpiry = cnicInfo.expiryDate

                return kycRepository.saveDocuments(documents, documentType: documentType,
                                                   identityNo: identityNo, nationality: nationality,
                                                   fullName: fullName, gender: gender, dob: dob,
                                                   dateIssue: dateIssue, dateExpiry: dateExpiry)
            }
            .share()

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
}
