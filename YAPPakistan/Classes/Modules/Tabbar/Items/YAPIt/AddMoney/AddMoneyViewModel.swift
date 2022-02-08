//
//  AddMoneyViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 08/02/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore
import YAPComponents

protocol AddMoneyViewModelInput {
    var closeObserver: AnyObserver<Void> { get }
    var actionObserver: AnyObserver<YapItTileAction> { get }
}

protocol AddMoneyViewModelOutput {
    var close: Observable<Void> { get }
    var action: Observable<YapItTileAction> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol AddMoneyViewModelType {
    var inputs: AddMoneyViewModelInput { get }
    var outputs: AddMoneyViewModelOutput { get }
}

class AddMoneyViewModel: AddMoneyViewModelInput, AddMoneyViewModelOutput, AddMoneyViewModelType {
    
    var inputs: AddMoneyViewModelInput { self }
    var outputs: AddMoneyViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    
    private let closeSubject = PublishSubject<Void>()
    private let actionSubject = PublishSubject<YapItTileAction>()
    private let cellViewModelsSubject  = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    // MARK: - Inputs
    
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var actionObserver: AnyObserver<YapItTileAction> { actionSubject.asObserver() }
    
    // MARK: - Outputs
    
    var close: Observable<Void> { closeSubject.asObservable() }
    var action: Observable<YapItTileAction> { actionSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    
    init() {
        
        let actions: [YapItTileAction] = [.topupViaCard, .bankTransfer, .cashOrCheque, .qrCode, .requestMoeny]
        
        let res = actions.map { YapItTileCellViewModel($0) }
        cellViewModelsSubject.onNext([SectionModel(model: 0, items: res)])
    }
}
