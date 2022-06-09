//
//  DashboardMissingDocumentViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 08/06/2022.
//

import Foundation
import RxSwift
import YAPComponents


protocol DashboardMissingDocumentViewModelInputs {
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<Void> { get }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{ get }
    var doItLaterObserver: AnyObserver<Void> { get }
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
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var actionObserver: AnyObserver<Void>{  actionSubject.asObserver() }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{  selectPackageSubject.asObserver() }
    var doItLaterObserver: AnyObserver<Void> { doItLaterSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var action: Observable<Void>{  actionSubject.asObservable() }
    
    var cellViewModels: Observable<[MissingDocumentNameCellViewModel]> {  cellViewModelsSubject.asObservable() }
    var presentTourGuide: Observable<Void> { presentTourGuideSubject }
    var selectStorePackage: Observable<StorePackageType>{  selectPackageSubject.asObservable() }
    var doItLater: Observable<Void> { doItLaterSubject.asObservable() }
    var titleName: Observable<String> { titleNameSubject.asObservable() }
    
    init() {
       // makePackages()
        
       
        
        let vm = MissingDocumentNameCellViewModel(MissingDocumentData(title: "1. CNIC copy", type: .cnicCopy))
        cellViewModelsSubject.onNext([vm])
        
        titleNameSubject.onNext("Hey Shayad")
    }
    
//    private func makePackages() {
//        Observable.of(YAPStore.mock)
//            .map{ $0.map{ StorePackageTableViewCellViewModel($0) } }
//            .subscribe(onNext: {[unowned self] storeInformation in
//                self.StorePackageCellViewModelSubject.onNext(storeInformation)
//            }).disposed(by: disposeBag)
//    }
    
    func sectionViewModel(for: Int) -> DocumentMissingHeaderCellViewModelType {
        return DocumentMissingHeaderCellViewModel(title: "Review required for:")
    }
}

