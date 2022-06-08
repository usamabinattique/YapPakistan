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
    var StoreInformationCellViewModel: Observable<[StorePackageTableViewCellViewModel]>{ get }
    var action: Observable<Void> { get }
    var presentTourGuide: Observable<Void> { get }
    var selectStorePackage: Observable<StorePackageType>{ get }
    var doItLater: Observable<Void> { get }
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
    private let StorePackageCellViewModelSubject = BehaviorSubject<[StorePackageTableViewCellViewModel]>(value: [])
    private let actionSubject = PublishSubject<Void>()
    private let storeTourGuideSubject = PublishSubject<[StoreTourGuide]>()
    private let presentTourGuideSubject = PublishSubject<Void>()
    private let selectPackageSubject = PublishSubject<StorePackageType>()
    private let doItLaterSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var actionObserver: AnyObserver<Void>{  actionSubject.asObserver() }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{  selectPackageSubject.asObserver() }
    var doItLaterObserver: AnyObserver<Void> { doItLaterSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var action: Observable<Void>{  actionSubject.asObservable() }
    
    var StoreInformationCellViewModel: Observable<[StorePackageTableViewCellViewModel]> {  StorePackageCellViewModelSubject.asObservable() }
    var presentTourGuide: Observable<Void> { presentTourGuideSubject }
    var selectStorePackage: Observable<StorePackageType>{  selectPackageSubject.asObservable() }
    var doItLater: Observable<Void> { doItLaterSubject.asObservable() }
    
    init() {
        makePackages()
        
    }
    
    private func makePackages() {
        Observable.of(YAPStore.mock)
            .map{ $0.map{ StorePackageTableViewCellViewModel($0) } }
            .subscribe(onNext: {[unowned self] storeInformation in
                self.StorePackageCellViewModelSubject.onNext(storeInformation)
            }).disposed(by: disposeBag)
    }
}

