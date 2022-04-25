//
//  HideWidgetPopupViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 21/04/2022.
//

import Foundation
import RxSwift

/*
class HideWidgetPopupViewModel {
    
    //MARK:- input
    var hideWidgetObserver: AnyObserver<Void> { hideWidgetSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { cancelSubject.asObserver() }
    
    //MARK:- outputs
    var hideWidget: Observable<Void> { hideWidgetSubject }
    var cancel: Observable<Void> { cancelSubject }
    
    //MARK:- Subjects
    private let hideWidgetSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    
    
    init() {
    }
} */


import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources

protocol HideWidgetPopupViewModelInput {
    var hideWidgetObserver: AnyObserver<Void> { get }
    var cancelObserver: AnyObserver<Void> { get }
}

protocol HideWidgetPopupViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var hideWidget: Observable<Void> { get }
    var cancel: Observable<Void> { get }
}

protocol HideWidgetPopupViewModelType {
    var inputs: HideWidgetPopupViewModelInput { get }
    var outputs: HideWidgetPopupViewModelOutput { get }
}

class HideWidgetPopupViewModel: HideWidgetPopupViewModelType, HideWidgetPopupViewModelInput, HideWidgetPopupViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: HideWidgetPopupViewModelInput { return self }
    var outputs: HideWidgetPopupViewModelOutput { return self }
    
    //MARK:- Subjects
    private let hideWidgetSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    private let dataSourceSubject = ReplaySubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>.create(bufferSize: 1)
    
    // MARK: - Inputs
    var hideWidgetObserver: AnyObserver<Void> { hideWidgetSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { cancelSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { dataSourceSubject.asObservable() }
    var hideWidget: Observable<Void> { hideWidgetSubject.asObservable() }
    var cancel: Observable<Void> { cancelSubject.asObservable() }
    
    // MARK: - Init
    init() {
       
        
        let vm = HideWidgetBottomSheetCellViewModel()
        vm.outputs.gotIt.bind(to: hideWidgetSubject).disposed(by: disposeBag)
        vm.outputs.cancel.bind(to: cancelSubject).disposed(by: disposeBag)
        
        dataSourceSubject.onNext([SectionModel(model: 0, items:  [vm])])
            
    }
}

