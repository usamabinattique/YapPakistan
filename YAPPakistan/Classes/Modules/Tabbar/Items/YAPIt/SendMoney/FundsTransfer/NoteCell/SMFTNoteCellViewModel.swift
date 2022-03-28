//
//  SMFTNoteCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol SMFTNoteCellViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var errorObserver: AnyObserver<String?> { get }
}

protocol SMFTNoteCellViewModelOutput {
    var text: Observable<String?> { get }
    var error: Observable<String?> { get }
}

protocol SMFTNoteCellViewModelType {
    var inputs: SMFTNoteCellViewModelInput { get }
    var outputs: SMFTNoteCellViewModelOutput { get }
}

class SMFTNoteCellViewModel: SMFTNoteCellViewModelType, SMFTNoteCellViewModelInput, SMFTNoteCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTNoteCellViewModelInput { return self }
    var outputs: SMFTNoteCellViewModelOutput { return self }
    var reusableIdentifier: String { SMFTNoteCell.defaultIdentifier }
    
    private let textSubject = BehaviorSubject<String?>(value: nil)
    private let errorSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var errorObserver: AnyObserver<String?> { errorSubject.asObserver() }
    
    // MARK: - Outputs
    var text: Observable<String?> { return textSubject.asObservable() }
    var error: Observable<String?> { errorSubject.asObservable() }
    
    // MARK: - Init
    init() {
        
    }
}
