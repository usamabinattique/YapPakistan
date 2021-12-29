//
//  WelcomeToYapCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol WelcomeToYapCellViewModelInput {
    
}

protocol WelcomeToYapCellViewModelOutput {
    
}

protocol WelcomeToYapCellViewModelType {
    var inputs: WelcomeToYapCellViewModelInput { get }
    var outputs: WelcomeToYapCellViewModelOutput { get }
}

class WelcomeToYapCellViewModel: WelcomeToYapCellViewModelType, WelcomeToYapCellViewModelInput, WelcomeToYapCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: WelcomeToYapCellViewModelInput { return self }
    var outputs: WelcomeToYapCellViewModelOutput { return self }
    var reusableIdentifier: String { WelcomeToYapCell.defaultIdentifier }
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    
    // MARK: - Init
    init() {
        
    }
}

