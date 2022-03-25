//
//  SMFTChargesCellViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol SMFTChargesCellViewModelInput {
    var feeObserver: AnyObserver<String> { get }
}

protocol SMFTChargesCellViewModelOutput {
    var charges: Observable<NSAttributedString?> { get }
}

protocol SMFTChargesCellViewModelType {
    var inputs: SMFTChargesCellViewModelInput { get }
    var outputs: SMFTChargesCellViewModelOutput { get }
}

class SMFTChargesCellViewModel: SMFTChargesCellViewModelType, SMFTChargesCellViewModelOutput, SMFTChargesCellViewModelInput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTChargesCellViewModelInput { return self }
    var outputs: SMFTChargesCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTChargesCell.defaultIdentifier }
    
    private let chargesSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let feeSubject = BehaviorSubject<String>(value: CurrencyFormatter.defaultFormattedFee)
    
    // MARK: - Inputs
    var feeObserver: AnyObserver<String> { return feeSubject.asObserver() }
    
    // MARK: - Outputs
    var charges: Observable<NSAttributedString?> { return chargesSubject.asObservable() }
    
    // MARK: - Init
    init(chargesType: ChargesType) {
        feeSubject.map { charges in
            let text = String.init(format: chargesType.chargesText, charges)
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor: UIColor.gray], range: (text as NSString).range(of: charges))
            return attributed
        }.bind(to: chargesSubject).disposed(by: disposeBag)
    }
}

extension SMFTChargesCellViewModel {
    enum ChargesType {
        case cashPickup
        case internationalTransfer
    }
}

extension SMFTChargesCellViewModel.ChargesType {
    var chargesText: String {
        switch self {
        case .cashPickup:
            return  "screen_cash_pickup_funds_display_text_fee".localized
        case .internationalTransfer:
            return  "screen_international_funds_transfer_display_text_fee_amount".localized
        
        }
    }
}
