//
//  SMFTPOPCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

protocol SMFTPOPCellViewModelInput {
    
}

protocol SMFTPOPCellViewModelOutput {
    var title: Observable<String?> { get }
    var showsSeperator: Observable<Bool> { get }
}

protocol SMFTPOPCellViewModelType {
    var inputs: SMFTPOPCellViewModelInput { get }
    var outputs: SMFTPOPCellViewModelOutput { get }
}

class SMFTPOPCellViewModel: SMFTPOPCellViewModelType, SMFTPOPCellViewModelInput, SMFTPOPCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTPOPCellViewModelInput { return self }
    var outputs: SMFTPOPCellViewModelOutput { return self }
    var reusableIdentifier: String { SMFTPOPCell.defaultIdentifier }
    
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let showsSeperatorSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var title: Observable<String?> { titleSubject.asObservable() }
    var showsSeperator: Observable<Bool> { showsSeperatorSubject.asObservable() }
    
    let reason: TransferReason?
    
    // MARK: - Init
    init(_ reason: TransferReason, isLast: Bool) {
        self.reason = reason
        showsSeperatorSubject.onNext(isLast)
        titleSubject.onNext(reason.transferReason)
    }
}

