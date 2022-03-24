//
//  ASMBBankInfoCellViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import UIKit

protocol ASMBBankInfoCellViewModelInput {
    
}

protocol ASMBBankInfoCellViewModelOutput {
    var image: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var address: Observable<String?> { get }
}

protocol ASMBBankInfoCellViewModelType {
    var inputs: ASMBBankInfoCellViewModelInput { get }
    var outputs: ASMBBankInfoCellViewModelOutput { get }
}

class ASMBBankInfoCellViewModel: ASMBBankInfoCellViewModelType, ASMBBankInfoCellViewModelInput, ASMBBankInfoCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ASMBBankInfoCellViewModelInput { return self }
    var outputs: ASMBBankInfoCellViewModelOutput { return self }
    var reusableIdentifier: String { return ASMBBankInfoCell.defaultIdentifier }
    
    private let imageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let addressSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var image: Observable<(String?, UIImage?)> { return imageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var address: Observable<String?> { return addressSubject.asObservable() }
    
    // MARK: - Init
    init(_ beneficiary: SendMoneyBeneficiary) {
        imageSubject.onNext((nil, beneficiary.bankName?.initialsImage(color: .darkGray)))
        nameSubject.onNext(beneficiary.bankName)
        addressSubject.onNext([beneficiary.branchAddress, beneficiary.phoneNumber].compactMap { $0 }.joined(separator: "\n"))
    }
}
