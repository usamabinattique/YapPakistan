//
//  StoreViewModelInputs.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import RxSwift
import YAPComponents

enum PackageType {
    case yapYoung
    case yapHousehold
}

public typealias StoreTourGuide = (title: String, desc: String, buttonTitle: String? , x: Int, y: Int, radius: Int)

protocol StoreViewModelInputs {
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<Void> { get }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{ get }
}

protocol StoreViewModelOutputs {
    var viewDidAppear: Observable<Void> { get }
    var StoreInformationCellViewModel: Observable<[StorePackageTableViewCellViewModel]>{ get }
    var action: Observable<Void> { get }
    var presentTourGuide: Observable<Void> { get }
    var selectStorePackage: Observable<StorePackageType>{ get }
}

protocol StoreViewModelType {
    var inputs: StoreViewModelInputs { get }
    var outputs: StoreViewModelOutputs { get }
}

class StoreViewModel: StoreViewModelType, StoreViewModelInputs, StoreViewModelOutputs {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: StoreViewModelInputs { return self}
    var outputs: StoreViewModelOutputs { return self }
    
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let StorePackageCellViewModelSubject = BehaviorSubject<[StorePackageTableViewCellViewModel]>(value: [])
    private let actionSubject = PublishSubject<Void>()
    private let storeTourGuideSubject = PublishSubject<[StoreTourGuide]>()
    private let presentTourGuideSubject = PublishSubject<Void>()
    private let selectPackageSubject = PublishSubject<StorePackageType>()
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var actionObserver: AnyObserver<Void>{ return actionSubject.asObserver() }
    var selectStorePackageObserver: AnyObserver<StorePackageType>{ return selectPackageSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var action: Observable<Void>{ return actionSubject.asObservable() }
    
    var StoreInformationCellViewModel: Observable<[StorePackageTableViewCellViewModel]> { return StorePackageCellViewModelSubject.asObservable() }
    var presentTourGuide: Observable<Void> { presentTourGuideSubject }
    var selectStorePackage: Observable<StorePackageType>{ return selectPackageSubject.asObservable() }
    
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

