//
//  SendMoneySearchCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 19/01/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol SendMoneySearchCellViewModelInput {
    
}

protocol SendMoneySearchCellViewModelOutput {
    var image: Observable<ImageWithURL> { get }
    var title: Observable<String?> { get }
    var subTitle: Observable<String?> { get }
    var flag: Observable<UIImage?> { get }
    var tranferTypeIcon: Observable<UIImage?> { get }
}

protocol SendMoneySearchCellViewModelType {
    var inputs: SendMoneySearchCellViewModel { get }
    var outputs: SendMoneySearchCellViewModel { get }
}

class SendMoneySearchCellViewModel: SendMoneySearchCellViewModelInput, SendMoneySearchCellViewModelOutput, SendMoneySearchCellViewModelType, ReusableTableViewCellViewModelType {
    
    var inputs: SendMoneySearchCellViewModel { self }
    var outputs: SendMoneySearchCellViewModel { self }
    var reusableIdentifier: String { SendMoneySearchCell.defaultIdentifier }
    
    private let imageSubject: BehaviorSubject<ImageWithURL>
    private let titleSubject: BehaviorSubject<String?>
    private let subTitleSubject: BehaviorSubject<String?>
    private let flagSubject: BehaviorSubject<UIImage?>
    private let transferTypeIconSubject: BehaviorSubject<UIImage?>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    
    var image: Observable<ImageWithURL> { imageSubject.asObservable() }
    var title: Observable<String?> { titleSubject.asObservable() }
    var subTitle: Observable<String?> { subTitleSubject.asObservable() }
    var flag: Observable<UIImage?> { flagSubject.asObservable() }
    var tranferTypeIcon: Observable<UIImage?> { transferTypeIconSubject.asObservable() }
    
    let beneficiary: SearchableBeneficiaryType!
    
    init( beneficiary: SearchableBeneficiaryType) {
        self.beneficiary = beneficiary
        imageSubject  = BehaviorSubject(value: beneficiary.searchableIcon)
        titleSubject = BehaviorSubject(value: beneficiary.searchableTitle)
        subTitleSubject = BehaviorSubject(value: beneficiary.searchableSubTitle)
        flagSubject = BehaviorSubject(value: beneficiary.searchableIndicator)
        transferTypeIconSubject = BehaviorSubject(value: beneficiary.searchableTransferType.typeIcon)
    }
}

fileprivate extension SearchableBeneficiaryTransferType {
    var typeIcon: UIImage? {
        switch self {
        case .y2y:
            return nil
        case .cashPayout:
            return UIImage(named: "icon_cash_pickup", in: .yapPakistan)?.asTemplate
        case .rmt, .swift, .uaefts, .domestic:
            return UIImage(named: "icon_bank_transfer", in: .yapPakistan)?.asTemplate
        }
    }
}

