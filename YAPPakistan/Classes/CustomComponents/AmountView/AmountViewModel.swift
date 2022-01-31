//
//  AmountViewModel.swift
//  YAPComponents
//
//  Created by Yasir on 24/01/2022.
//

import Foundation
import Foundation
import RxSwift
import RxCocoa

public protocol AmountViewModelInputs {
    var headingObserver: AnyObserver<String?> { get }
    var amountObserver: AnyObserver<String?> { get }
}

public protocol AmountViewModelOutputs {
    var heading: Observable<String?> { get }
    var amount: Observable<String?> { get }
}

public protocol AmountViewModelType {
    var inputs: AmountViewModelInputs { get }
    var outputs: AmountViewModelOutputs { get }
}

public class AmountViewModel: AmountViewModelType, AmountViewModelInputs, AmountViewModelOutputs {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: AmountViewModelInputs { return self}
    public var outputs: AmountViewModelOutputs { return self }
    
    private let headingSubject: BehaviorSubject<String?>
    private let amountSubject: BehaviorSubject<String?>
    
    // MARK: - Inputs
    public var headingObserver: AnyObserver<String?> { return headingSubject.asObserver() }
    public var amountObserver: AnyObserver<String?> { return amountSubject.asObserver() }
    
    // MARK: - Outputs
    public var heading: Observable<String?> { return headingSubject.asObservable() }
    public var amount: Observable<String?> { return amountSubject.asObservable() }
    
    public init(heading: String, amount: String = "") {
        headingSubject = BehaviorSubject(value: heading)
        amountSubject = BehaviorSubject(value: amount)
    }
    
}
