//
//  TDTransactionOptionsTableViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

protocol TDTransactionOptionsTableViewModelInputs {
    
}

protocol TDTransactionOptionsTableViewModelOutputs {
    var actionTitle: Observable<String?> { get }
    var actionDescription: Observable<String?> { get }
    var actionLogo: Observable<UIImage?> { get }
}

protocol TDTransactionOptionsTableViewModelType {
    var inputs: TDTransactionOptionsTableViewModelInputs { get }
    var outputs: TDTransactionOptionsTableViewModelOutputs { get }
}

class TDTransactionOptionsTableViewModel: TDTransactionOptionsTableViewModelType, ReusableTableViewCellViewModelType, TDTransactionOptionsTableViewModelInputs, TDTransactionOptionsTableViewModelOutputs {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDTransactionOptionsTableViewCell.defaultIdentifier }
    
    var inputs: TDTransactionOptionsTableViewModelInputs { return self}
    var outputs: TDTransactionOptionsTableViewModelOutputs { return self }
    
    private let actionTitleSubject: BehaviorSubject<String?>
    private let actionDescriptionSubject: BehaviorSubject<String?>
    private let actionLogoSubject: BehaviorSubject<UIImage?>
    
    // MARK: - inputs
    
    // MARK: - outputs
    var actionTitle: Observable<String?> { return actionTitleSubject.asObservable() }
    var actionDescription: Observable<String?> { return actionDescriptionSubject.asObservable() }
    var actionLogo: Observable<UIImage?> { return actionLogoSubject.asObservable() }
    
    init(actionTitle: String, actionDescription: String, actionLogo: UIImage) {
        actionLogoSubject = BehaviorSubject(value: actionLogo)
        actionTitleSubject = BehaviorSubject(value: actionTitle)
        actionDescriptionSubject = BehaviorSubject(value: actionDescription)
    }
}
