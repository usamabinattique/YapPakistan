//
//  SMFTAvailableBalanceCellViewModel.swift
//  YAP
//
//  Created by Zain on 17/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol SMFTAvailableBalanceCellViewModelInput {
    
}

protocol SMFTAvailableBalanceCellViewModelOutput {
    var balance: Observable<NSAttributedString?> { get }
    var addPadding: Observable<Bool> { get }
}

protocol SMFTAvailableBalanceCellViewModelType {
    var inputs: SMFTAvailableBalanceCellViewModelInput { get }
    var outputs: SMFTAvailableBalanceCellViewModelOutput { get }
}

class SMFTAvailableBalanceCellViewModel: SMFTAvailableBalanceCellViewModelType, SMFTAvailableBalanceCellViewModelInput, SMFTAvailableBalanceCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTAvailableBalanceCellViewModelInput { return self }
    var outputs: SMFTAvailableBalanceCellViewModelOutput { return self }
    var reusableIdentifier: String { SMFTAvailableBalanceCell.defaultIdentifier }
    private let balanceSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let addPaddingSubject: BehaviorSubject<Bool>
    private var accountProvider: AccountProvider!
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var balance: Observable<NSAttributedString?> { balanceSubject.asObservable() }
    var addPadding: Observable<Bool> { addPaddingSubject.asObservable() }
    
    // MARK: - Init
    init(_ addPaddingToTop: Bool = false) {
        addPaddingSubject = BehaviorSubject(value: addPaddingToTop)
//        self.accountProvider.currentAccount.currentBalance
//            .map{ accountBalance -> NSAttributedString in
//
//                let balance = accountBalance.formattedBalance()
//                let text = "Your available balance is \(balance)"
//
//                let attributed = NSMutableAttributedString(string: text)
//                attributed.addAttributes([.foregroundColor : UIColor.primaryDark], range: NSRange(location: text.count - balance.count, length: balance.count))
//
//                return attributed }
//            .bind(to: balanceSubject)
//            .disposed(by: disposeBag)
    }
}

