//
//  SMFTReasonCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol SMFTReasonCellViewModelInput {
    var selectReasonObserver: AnyObserver<Void> { get }
    var selectedReasonObserver: AnyObserver<TransferReason> { get }
}

protocol SMFTReasonCellViewModelOutput {
    var text: Observable<String?> { get }
    var title: Observable<String?> { get }
    var endEditting: Observable<Bool> { get }
    var selectReason: Observable<Void> { get }
}

protocol SMFTReasonCellViewModelType {
    var inputs: SMFTReasonCellViewModelInput { get }
    var outputs: SMFTReasonCellViewModelOutput { get }
}

class SMFTReasonCellViewModel: SMFTReasonCellViewModelType, SMFTReasonCellViewModelInput, SMFTReasonCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTReasonCellViewModelInput { return self }
    var outputs: SMFTReasonCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTReasonCell.defaultIdentifier }
    
    private let textSubject = BehaviorSubject<String?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let endEdittingSubject = PublishSubject<Bool>()
    private let selectReasonSubject = PublishSubject<Void>()
    private let selectedReasonSubject = PublishSubject<TransferReason>()
    
    // MARK: - Inputs
    var selectReasonObserver: AnyObserver<Void> { selectReasonSubject.asObserver() }
    var selectedReasonObserver: AnyObserver<TransferReason> { selectedReasonSubject.asObserver() }
    
    // MARK: - Outputs
    var text: Observable<String?> { return textSubject.asObservable() }
    var endEditting: Observable<Bool> { return endEdittingSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var selectReason: Observable<Void> { selectReasonSubject.asObservable() }
    
    // MARK: - Init
    init() {
        titleSubject.onNext("screen_international_funds_transfer_display_text_reson".localized)
        selectedReasonSubject.map{ $0.text }.bind(to: textSubject).disposed(by: disposeBag)
    }
}
