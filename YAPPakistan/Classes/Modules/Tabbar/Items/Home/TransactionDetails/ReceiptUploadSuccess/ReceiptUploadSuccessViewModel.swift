//
//  ReceiptUploadSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 30/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol ReceiptUploadSuccessViewModelInput {
    
}

protocol ReceiptUploadSuccessViewModelOutput {
    
}

protocol ReceiptUploadSuccessViewModelType {
    var inputs: ReceiptUploadSuccessViewModelInput { get }
    var outputs: ReceiptUploadSuccessViewModelOutput { get }
}

class ReceiptUploadSuccessViewModel: ReceiptUploadSuccessViewModelType, ReceiptUploadSuccessViewModelInput, ReceiptUploadSuccessViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ReceiptUploadSuccessViewModelInput { return self }
    var outputs: ReceiptUploadSuccessViewModelOutput { return self }
    
    
    // MARK: - Init
    init() {
        
    }
}

