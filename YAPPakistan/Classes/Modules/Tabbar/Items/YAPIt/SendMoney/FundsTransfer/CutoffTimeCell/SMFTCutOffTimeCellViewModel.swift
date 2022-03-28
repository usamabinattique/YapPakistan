//
//  SMFTCutOffTimeCellViewModel.swift
//  YAP
//
//  Created by Zain on 23/01/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol SMFTCutOffTimeCellViewModelInput {
}

protocol SMFTCutOffTimeCellViewModelOutput {
    var cutOffTime: Observable<String?> { get }
}

protocol SMFTCutOffTimeCellViewModelType {
    var inputs: SMFTCutOffTimeCellViewModelInput { get }
    var outputs: SMFTCutOffTimeCellViewModelOutput { get }
}

class SMFTCutOffTimeCellViewModel: SMFTCutOffTimeCellViewModelType, SMFTCutOffTimeCellViewModelInput, SMFTCutOffTimeCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTCutOffTimeCellViewModelInput { self }
    var outputs: SMFTCutOffTimeCellViewModelOutput { self }
    var reusableIdentifier: String { SMFTCutOffTimeCell.defaultIdentifier }
    
    private let cutOffTimeSubject: BehaviorSubject<String?>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var cutOffTime: Observable<String?> { cutOffTimeSubject.asObservable() }
    
    // MARK: - Init
    init(cutOffTime: String) {        
        cutOffTimeSubject = BehaviorSubject<String?>(value: cutOffTime)
    }
}

