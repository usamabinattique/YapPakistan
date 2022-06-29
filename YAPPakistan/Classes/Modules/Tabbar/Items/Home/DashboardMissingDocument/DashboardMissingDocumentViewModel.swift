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


protocol DashboardMissingDocumentViewModelInputs {
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<Void> { get }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{ get }
    var doItLaterObserver: AnyObserver<Void> { get }
    var getStartedObserver: AnyObserver<Void> { get }
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
    
    private var transactionRepository: TransactionsRepositoryType
    private var accountProvider: AccountProvider!
    private var requiredDocuments = [RequiredDocument]()
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var actionObserver: AnyObserver<Void>{  actionSubject.asObserver() }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{  selectPackageSubject.asObserver() }
    var doItLaterObserver: AnyObserver<Void> { doItLaterSubject.asObserver() }
    var getStartedObserver: AnyObserver<Void> { getStartedSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var action: Observable<Void>{  actionSubject.asObservable() }
    
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
    
    init(accountProvider: AccountProvider, transactionRepository: TransactionsRepositoryType) {
        self.transactionRepository = transactionRepository
        self.accountProvider = accountProvider
        let name = accountProvider.currentAccountValue.value?.customer.firstName ?? ""
        titleNameSubject.onNext("Hey \(name)")
        getRequiredDocuments()
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
}

