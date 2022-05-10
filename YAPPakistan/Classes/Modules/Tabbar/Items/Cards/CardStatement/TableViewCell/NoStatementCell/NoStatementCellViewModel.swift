//
//  PaymentCardNoStatementCellViewModel.swift
//  YAP
//
//  Created by Zain on 17/01/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol NoStatementCellViewModelInput {
    
}

protocol NoStatementCellViewModelOutput {
    
}

protocol NoStatementCellViewModelType {
    var inputs: NoStatementCellViewModelInput { get }
    var outputs: NoStatementCellViewModelOutput { get }
}

class NoStatementCellViewModel: NoStatementCellViewModelType, NoStatementCellViewModelInput, NoStatementCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: NoStatementCellViewModelInput { return self }
    var outputs: NoStatementCellViewModelOutput { return self }
    var reusableIdentifier: String { NoStatementCell.defaultIdentifier }
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    
    // MARK: - Init
    init() {
        
    }
}

