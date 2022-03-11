//
//  DenominationAmountViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 05/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import Foundation
import RxSwift

public protocol DenominationAmountCollectionViewCellViewModelInputs {
    var amountObserver: AnyObserver<String> { get }
}

public protocol DenominationAmountCollectionViewCellViewModelOutputs {
    var amount: Observable<String> { get }
}

public protocol  DenominationAmountViewModelType {
    var inputs: DenominationAmountCollectionViewCellViewModelInputs { get }
    var outputs: DenominationAmountCollectionViewCellViewModelOutputs { get }
}

public class  DenominationAmountCollectionViewCellViewModel: DenominationAmountViewModelType, DenominationAmountCollectionViewCellViewModelInputs, DenominationAmountCollectionViewCellViewModelOutputs {
    
    public var inputs: DenominationAmountCollectionViewCellViewModelInputs { return self}
    public var outputs: DenominationAmountCollectionViewCellViewModelOutputs { return self }
    
    private var amountSubject: BehaviorSubject<String>
    
    // MARK: Inputs
    public var amountObserver: AnyObserver<String> { return amountSubject.asObserver() }
    
    // MARK: Outputs
    public var amount: Observable<String> { return amountSubject.asObservable() }
    
    // MARK: Class Properties
    internal let disposeBag = DisposeBag()
    
    // MARK: Init
    public init(amount: String) {
        amountSubject = BehaviorSubject(value: amount)
    }
    
}
