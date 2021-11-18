//
//  YAPItViewModel.swift
//  YAP
//
//  Created by Zain on 01/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol YAPItViewModelInput {
    var addMoneyObserver: AnyObserver<Void> { get }
    var payBillsObserver: AnyObserver<Void> { get }
    var sendMoneyObserver: AnyObserver<Void> { get }
    var hideObserver: AnyObserver<Void> { get }
}

protocol YAPItViewModelOutput {
    var addMoney: Observable<Void> { get }
    var payBills: Observable<Void> { get }
    var sendMoney: Observable<Void> { get }
    var hide: Observable<Void> { get }
    
}

protocol YAPItViewModelType {
    var inputs: YAPItViewModelInput { get }
    var outputs: YAPItViewModelOutput { get }
}

class YAPItViewModel: YAPItViewModelType, YAPItViewModelInput, YAPItViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: YAPItViewModelInput { return self }
    var outputs: YAPItViewModelOutput { return self }
    
    private let addMoneySubject = PublishSubject<Void>()
    private let payBillsSubject = PublishSubject<Void>()
    private let sendMoneySubject = PublishSubject<Void>()
    private let hideSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var addMoneyObserver: AnyObserver<Void> { return addMoneySubject.asObserver() }
    var payBillsObserver: AnyObserver<Void> { return payBillsSubject.asObserver() }
    var sendMoneyObserver: AnyObserver<Void> { return sendMoneySubject.asObserver() }
    var hideObserver: AnyObserver<Void> { return hideSubject.asObserver() }
    
    // MARK: - Outputs
    var addMoney: Observable<Void> { return addMoneySubject.asObservable() }
    var payBills: Observable<Void> { return payBillsSubject.asObservable() }
    var sendMoney: Observable<Void> { return sendMoneySubject.asObservable() }
    var hide: Observable<Void> { return hideSubject.asObservable() }
    
    // MARK: - Init
    init() {
        
    }
}
