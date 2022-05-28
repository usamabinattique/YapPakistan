//
//  TransactionDetailImproveAttributesCellViewModel.swift
//  Cards
//
//  Created by Muhammad Hassan on 26/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

public class TransactionDetailImproveAttributesCellViewModel: ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    public var reusableIdentifier: String { TransactionDetailImproveAttributesCell.defaultIdentifier }
    
    // MARK: - Outputs
    //TODO: check Observalble here
    var title: Observable<String> { Observable.just( "screen_transaction_details_display_text_improve_attribute".localized) } //Observable<String> { Observable.createForever(element: "screen_transaction_details_display_text_improve_attribute".localized) }
    
}
