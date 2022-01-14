//
//  RecentBeneficiaryViewModel.swift
//  YAPKit
//
//  Created by Zain on 02/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

public protocol RecentBeneficiaryViewModelInput {
    var itemSelectedObserver: AnyObserver<Int> { get }
    var showObserver: AnyObserver<Void> { get }
    var hideObserver: AnyObserver<Void> { get }
    var recentBeneficiaryObserver: AnyObserver<[RecentBeneficiaryType]> { get }
}

public protocol RecentBeneficiaryViewModelOutput {
    var itemSelected: Observable<Int> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var isShown: Observable<Bool> { get }
    
    var heading: Observable<String?> { get }
    var showButtonTitle: Observable<String?> { get }
    var hideButtonTitle: Observable<String?> { get }
}

public protocol RecentBeneficiaryViewModelType {
    var inputs: RecentBeneficiaryViewModelInput { get }
    var outputs: RecentBeneficiaryViewModelOutput { get }
}

public class RecentBeneficiaryViewModel: RecentBeneficiaryViewModelInput, RecentBeneficiaryViewModelOutput, RecentBeneficiaryViewModelType {
    
    public var inputs: RecentBeneficiaryViewModelInput { self }
    public var outputs: RecentBeneficiaryViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    
    private let itemSelectedSubject = PublishSubject<Int>()
    private let cellViewModelsSubject: BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>
    private let isShownSubject = BehaviorSubject<Bool>(value: true)
    private let showSubject = PublishSubject<Void>()
    private let hideSubject = PublishSubject<Void>()
    private let headingSubject: BehaviorSubject<String?>
    private let showButtonTitleSubject: BehaviorSubject<String?>
    private let hideButtonTitleSubject: BehaviorSubject<String?>
    private let recentBeneficiarySubject: BehaviorSubject<[RecentBeneficiaryType]>
    public var recentBeneficiaryObserver: AnyObserver<[RecentBeneficiaryType]> { recentBeneficiarySubject.asObserver() }
    
    // MARK: - Inputs
    
    public var itemSelectedObserver: AnyObserver<Int> { itemSelectedSubject.asObserver() }
    public var showObserver: AnyObserver<Void> { showSubject.asObserver() }
    public var hideObserver: AnyObserver<Void> { hideSubject.asObserver() }
    
    // MARK: - Outputs
    
    public var itemSelected: Observable<Int> { itemSelectedSubject.asObservable() }
    public var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    public var isShown: Observable<Bool> { isShownSubject.asObservable() }
    public var heading: Observable<String?> { headingSubject.asObservable() }
    public var showButtonTitle: Observable<String?> { showButtonTitleSubject.asObservable() }
    public var hideButtonTitle: Observable<String?> { hideButtonTitleSubject.asObservable() }
    
    // MARK: - Initialization
    
    public init(_ beneficiaries: [RecentBeneficiaryType]? = nil) {
        
        cellViewModelsSubject = BehaviorSubject(value: [SectionModel(model: 0, items: (beneficiaries ?? []).map{ RecentBeneficiaryCollectionViewCellViewModel($0) })])
        headingSubject = BehaviorSubject(value: "Recent transfers")
        showButtonTitleSubject = BehaviorSubject(value: "Show recent transfers")
        hideButtonTitleSubject = BehaviorSubject(value: "Hide")
        recentBeneficiarySubject = BehaviorSubject(value: (beneficiaries ?? []))
        
        loadData()
        showHide()
    }
    
}

private extension RecentBeneficiaryViewModel {
    func loadData() {
        recentBeneficiarySubject
            .map{ [SectionModel(model: 0, items: $0.map{ RecentBeneficiaryCollectionViewCellViewModel($0) })] }
            .bind(to: cellViewModelsSubject)
            .disposed(by: disposeBag)
    }
    
    func showHide() {
        showSubject.map{ _ in true }.bind(to: isShownSubject).disposed(by: disposeBag)
        hideSubject.map{ _ in false }.bind(to: isShownSubject).disposed(by: disposeBag)
    }
}
