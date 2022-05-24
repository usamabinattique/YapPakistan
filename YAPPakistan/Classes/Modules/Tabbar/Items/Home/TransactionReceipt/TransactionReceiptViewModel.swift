//
//  TransactionReceiptViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol TransactionReceiptViewModelInput {
    
}

protocol TransactionReceiptViewModelOutput {
}

protocol TransactionReceiptViewModelType {
    var inputs: TransactionReceiptViewModelInput { get }
    var outputs: TransactionReceiptViewModelOutput { get }
}

class TransactionReceiptViewModel: TransactionReceiptViewModelType, TransactionReceiptViewModelInput, TransactionReceiptViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionReceiptViewModelInput { return self }
    var outputs: TransactionReceiptViewModelOutput { return self }
    
    // MARK: - Init
    init() {
    }
    
    
}

