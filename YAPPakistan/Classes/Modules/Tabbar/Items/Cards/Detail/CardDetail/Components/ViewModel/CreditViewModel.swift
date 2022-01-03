//
//  CreditViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CreditViewModelInputs {
    var balanceObserver: Observable<Double> { get }
}

protocol CreditViewModelOutputs {
    var title: Observable<String> { get }
    var balance: Observable<String> { get }
}

protocol CreditViewModelType {
    var inputs: CreditViewModelInputs { get }
    var outputs: CreditViewModelOutputs { get }
}

struct CreditViewModel: CreditViewModelType, CreditViewModelInputs, CreditViewModelOutputs {

    // Subjects
    fileprivate var balanceSubject = PublishSubject<Double>()
    
    fileprivate var titleSubject = BehaviorSubject<String>(value: "")
    fileprivate var balanceFormatedSubject = BehaviorSubject<String>(value: "PKR 0")

    // Inputs
    var balanceObserver: Observable<Double> { balanceSubject.asObservable() }

    // Outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var balance: Observable<String> { balanceFormatedSubject.asObservable() }

    var inputs: CreditViewModelInputs { self }
    var outputs: CreditViewModelOutputs { self }

    // Properties
    private let disposeBag = DisposeBag()

    init() {
        balanceSubject
            .map{ "PKR \($0)" }
            .bind(to: balanceFormatedSubject)
            .disposed(by: disposeBag)

        titleSubject.onNext("Card balance")
        //balanceSubject.onNext(0)
    }
}
