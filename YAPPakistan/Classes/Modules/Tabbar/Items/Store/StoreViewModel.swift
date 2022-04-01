//
//  StoreViewModelInputs.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol StoreViewModelInputs {
    var completeVerificationObserver: AnyObserver<Void> { get }
}

protocol StoreViewModelOutputs {
    var completeVerification: Observable<Bool> { get }
    var completeVerificationHidden: Observable<Bool>  { get }
}

protocol StoreViewModelType {
    var inputs: StoreViewModelInputs { get }
    var outputs: StoreViewModelOutputs { get }
}

class StoreViewModel: StoreViewModelType, StoreViewModelInputs, StoreViewModelOutputs {

    var inputs: StoreViewModelInputs { return self }
    var outputs: StoreViewModelOutputs { return self }
    
    //MARK: Inputs
    var completeVerificationObserver: AnyObserver<Void> { completeVerificationSubject.asObserver() }
    
    //MARK: Outputs
    var completeVerification: Observable<Bool> { completeVerificationResultSubject.asObserver() }
    var completeVerificationHidden: Observable<Bool> { completeVerificationHiddenSubject.asObservable() }

    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    
    private let completeVerificationHiddenSubject = BehaviorSubject<Bool>(value: true)
    private let completeVerificationSubject = PublishSubject<Void>()
    private let completeVerificationResultSubject = PublishSubject<Bool>()

    // MARK: - Init
    init(accountProvider: AccountProvider) {
        
        accountProvider.currentAccount.unwrap()
            .map{ ($0.accountStatus?.stepValue ?? 0) >= AccountStatus.addressCaptured.stepValue }
            .bind(to: completeVerificationHiddenSubject)
            .disposed(by: disposeBag)

        completeVerificationSubject.withLatestFrom(accountProvider.currentAccount).unwrap()
            .map({ ($0.accountStatus?.stepValue ?? 100) < AccountStatus.addressCaptured.stepValue })
            .bind(to: completeVerificationResultSubject)
            .disposed(by: disposeBag)
    }
}

