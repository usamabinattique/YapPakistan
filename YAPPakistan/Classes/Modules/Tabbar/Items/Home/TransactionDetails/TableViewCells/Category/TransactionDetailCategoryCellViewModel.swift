//
//  TransactionDetailCategoryCellViewModel.swift
//  Cards
//
//  Created by Muhammad Hassan on 16/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme


class TransactionDetailCategoryCellViewModel: ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    var reusableIdentifier: String { TransactionDetailCategoryCell.defaultIdentifier }
    private let categorySubject: BehaviorSubject<String>
    private let subtitleSubject: BehaviorSubject<String>
    private let iconSubject: BehaviorSubject<ImageWithURL>
    
    // MARK: - Outputs
    var category: Observable<String> { categorySubject }
    var subtitle: Observable<String> { subtitleSubject }
    var icon: Observable<ImageWithURL> { iconSubject }
    
    // MAKR: - Init
    init(transaction: TransactionResponse,themeService: ThemeService<AppTheme>){ //CDTransaction) {
        let category = transaction.tapixCategory?.name ?? "General"
        let isCategoryGeneral = category.lowercased() == "general"
        categorySubject = BehaviorSubject(value: category)
        subtitleSubject = BehaviorSubject(value: isCategoryGeneral ? "screen_transaction_details_display_text_wait_for_category_to_update".localized : "screen_transaction_details_display_text_change_category".localized)
        
        //TODO: add image
        iconSubject = BehaviorSubject(value: isCategoryGeneral ? (nil, UIImage.init(named: "icon_general_primary", in: .yapPakistan, compatibleWith: nil)) : (transaction.tapixCategory?.iconUrl, category.initialsImage(color: UIColor(themeService.attrs.primary)))) //BehaviorSubject(value: isCategoryGeneral ? (nil, UIImage(named: "icon_general_primary", in: cardsBundle, compatibleWith: nil)) : (transaction.tapixCategoryIconURL, category.initialsImage(color: .primary)))
    }
}
