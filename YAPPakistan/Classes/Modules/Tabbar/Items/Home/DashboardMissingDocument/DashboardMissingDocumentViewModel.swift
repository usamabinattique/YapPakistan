//
//  DashboardMissingDocumentViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 08/06/2022.
//

import Foundation
import RxSwift
import YAPComponents
import Alamofire
import YAPCardScanner


protocol DashboardMissingDocumentViewModelInputs {
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<Void> { get }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{ get }
    var doItLaterObserver: AnyObserver<Void> { get }
    var getStartedObserver: AnyObserver<Void> { get }
    var cninScanResultObserver: AnyObserver<IdentityScannerResult> { get }
}

protocol DashboardMissingDocumentViewModelOutputs {
    var viewDidAppear: Observable<Void> { get }
    var cellViewModels: Observable<[MissingDocumentNameCellViewModel]>{ get }
    var action: Observable<Void> { get }
    var presentTourGuide: Observable<Void> { get }
    var selectStorePackage: Observable<StorePackageType>{ get }
    var doItLater: Observable<Void> { get }
    func sectionViewModel(for: Int) -> DocumentMissingHeaderCellViewModelType
    var titleName: Observable<String> { get }
    var error: Observable<Error> { get}
    var getStarted: Observable<MissingDocumentType?> { get }
    var cninScanResult: Observable<IdentityScannerResult> { get }
}

protocol DashboardMissingDocumentViewModelType {
    var inputs: DashboardMissingDocumentViewModelInputs { get }
    var outputs: DashboardMissingDocumentViewModelOutputs { get }
}

class DashboardMissingDocumentViewModel: DashboardMissingDocumentViewModelType, DashboardMissingDocumentViewModelInputs, DashboardMissingDocumentViewModelOutputs {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: DashboardMissingDocumentViewModelInputs { return self}
    var outputs: DashboardMissingDocumentViewModelOutputs { return self }
    
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let cellViewModelsSubject = BehaviorSubject<[MissingDocumentNameCellViewModel]>(value: [])
    private let actionSubject = PublishSubject<Void>()
    private let storeTourGuideSubject = PublishSubject<[StoreTourGuide]>()
    private let presentTourGuideSubject = PublishSubject<Void>()
    private let selectPackageSubject = PublishSubject<StorePackageType>()
    private let doItLaterSubject = PublishSubject<Void>()
    private let titleNameSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let errorSubject = PublishSubject<Error>()
    private let getStartedSubject = PublishSubject<Void>()
    private let cnicScanResultSubject = PublishSubject<IdentityScannerResult>()
    private let cnicOCRSubject = PublishSubject<CNICOCR>()
    
    private var transactionRepository: TransactionsRepositoryType
    private var kycRepository: KYCRepositoryType
    private var accountProvider: AccountProvider!
    private var requiredDocuments = [RequiredDocument]()
    
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var actionObserver: AnyObserver<Void>{  actionSubject.asObserver() }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{  selectPackageSubject.asObserver() }
    var doItLaterObserver: AnyObserver<Void> { doItLaterSubject.asObserver() }
    var getStartedObserver: AnyObserver<Void> { getStartedSubject.asObserver() }
    var cninScanResultObserver: AnyObserver<IdentityScannerResult> { cnicScanResultSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var action: Observable<Void>{  actionSubject.asObservable() }
    var cninScanResult: Observable<IdentityScannerResult> { cnicScanResultSubject.asObservable() }
    
    var cellViewModels: Observable<[MissingDocumentNameCellViewModel]> {  cellViewModelsSubject.asObservable() }
    var presentTourGuide: Observable<Void> { presentTourGuideSubject }
    var selectStorePackage: Observable<StorePackageType>{  selectPackageSubject.asObservable() }
    var doItLater: Observable<Void> { doItLaterSubject.asObservable() }
    var titleName: Observable<String> { titleNameSubject.asObservable() }
    var error: Observable<Error> { errorSubject.asObservable() }
    var getStarted: Observable<MissingDocumentType?> { getStartedSubject.map { [unowned self] _ -> MissingDocumentType? in
       let abc = self.requiredDocuments.filter { document in
           return document.uploaded == false
       }.first
        return abc?.documentType
    } }
    
    init(accountProvider: AccountProvider, transactionRepository: TransactionsRepositoryType, kycRepository: KYCRepositoryType) {
        self.transactionRepository = transactionRepository
        self.accountProvider = accountProvider
        self.kycRepository = kycRepository
        let name = accountProvider.currentAccountValue.value?.customer.firstName ?? ""
        titleNameSubject.onNext("Hey \(name)")
        getRequiredDocuments()
        getCNICOCRInfo(kycRepository: kycRepository)
        idCardReupload(kycRepository: kycRepository)
    }
    
    func sectionViewModel(for: Int) -> DocumentMissingHeaderCellViewModelType {
        return DocumentMissingHeaderCellViewModel(title: "Review required for:")
    }
    
    private func getRequiredDocuments() {
        YAPProgressHud.showProgressHud()
        let request = transactionRepository.fetchRequiredDocuments()
            .share()
        
        request.errors()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
                .bind(to: errorSubject).disposed(by: disposeBag)
                
        request.elements()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .subscribe(onNext: { [weak self]  in
                if let docs = $0 {
                    self?.requiredDocuments = docs
                    var vms = [MissingDocumentNameCellViewModel]()
                    for (index,document) in docs.enumerated() {
                        vms.append(MissingDocumentNameCellViewModel(MissingDocumentData(title: "\(index + 1): \(document.documentName)", type: document.documentType,isUploaded: document.uploaded)))
                    }
                    self?.cellViewModelsSubject.onNext(vms)
                }
            }).disposed(by: disposeBag)
    }
    
    private func getCNICOCRInfo(kycRepository: KYCRepositoryType) {
        let ocrRequest = cnicScanResultSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { identityDocument -> Observable<Event<CNICOCR?>> in
                let frontImage = identityDocument.identityDocument?.frontSide?.cropedImage
                guard let frontImageData = frontImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                let backImage = identityDocument.identityDocument?.backSide?.cropedImage
                guard let backImageData = backImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                var documents = [(fileName: String, data: Data, format: String)]()
                documents.append((fileName: "files_f", data: frontImageData, format: "image/jpg"))
                documents.append((fileName: "files_b", data: backImageData, format: "image/jpg"))

                return kycRepository.detectCNICInfo(documents, progressObserver: nil)
            }
            .do(onNext: { [weak self] _ in
                YAPProgressHud.hideProgressHud()
                //self?.documentsUploadObserver.onNext(())
            })
            .share()

        ocrRequest.elements()
                .unwrap()
                .subscribe(onNext:{ [weak self] ocrObj in
                    print("found ocrObject")
                    self?.cnicOCRSubject.onNext(ocrObj)
                })
            .disposed(by: disposeBag)

        ocrRequest.errors()
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
    private func idCardReupload(kycRepository: KYCRepositoryType) {
        
        let request = Observable.combineLatest(cnicScanResultSubject,cnicOCRSubject)
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { (arg1) -> Observable<Event<String?>> in
                let (identityResult, cnicOcr) = arg1
                
                let frontImage = identityResult.identityDocument?.frontSide?.cropedImage
                guard let frontImageData = frontImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                let backImage = identityResult.identityDocument?.backSide?.cropedImage
                guard let backImageData = backImage?.jpegData(compressionQuality: 0.5) else {
                    return .empty()
                }
                var documents = [(fileName: String, data: Data, format: String)]()
                documents.append((fileName: "files_f", data: frontImageData, format: "image/jpg"))
                documents.append((fileName: "files_b", data: backImageData, format: "image/jpg"))
                return kycRepository.idCardReupload(documents, progressObserver: nil, issueDate: cnicOcr.issueDate?.string(withFormat: "yyyy-MM-dd") ?? "", cnic: cnicOcr.cnicNumberWithoutSlashes)
                
            }.do(onNext: { [weak self] _ in
                YAPProgressHud.hideProgressHud()
            })
            .share()
                
                request.elements()
                .subscribe(onNext:{ [weak self] _ in
                    print("request succuss idCard Reupload")
                    self?.getRequiredDocuments()
                    
                })
                .disposed(by: disposeBag)
                
                request.errors()
                .bind(to: errorSubject)
                .disposed(by: disposeBag)
                
                request.errors()
                .subscribe(onNext:{  _ in
                    print("request error idCard Reupload")
                })
                .disposed(by: disposeBag)
        }
    
}

