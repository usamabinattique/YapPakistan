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
    var doneObserver: AnyObserver<Void> { get }
    var addAnotherReceiptObserver: AnyObserver<Void> { get }
}

protocol ReceiptUploadSuccessViewModelOutput {
    var done: Observable<Void> { get }
    var addAnotherReceipt: Observable<Void> { get }
}

protocol ReceiptUploadSuccessViewModelType {
    var inputs: ReceiptUploadSuccessViewModelInput { get }
    var outputs: ReceiptUploadSuccessViewModelOutput { get }
}

class ReceiptUploadSuccessViewModel: ReceiptUploadSuccessViewModelType, ReceiptUploadSuccessViewModelInput, ReceiptUploadSuccessViewModelOutput {

    
    // MARK: Subjects
    private let doneSubject = PublishSubject<Void>()
    private let addAnotherReceiptSubject = PublishSubject<Void>()
    
    // MARK: Inputs
    var doneObserver: AnyObserver<Void> { doneSubject.asObserver() }
    var addAnotherReceiptObserver: AnyObserver<Void> { addAnotherReceiptSubject.asObserver() }
    
    // MARK: Outputs
    var done: Observable<Void> { doneSubject.asObservable() }
    var addAnotherReceipt: Observable<Void> { addAnotherReceiptSubject.asObservable() }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ReceiptUploadSuccessViewModelInput { return self }
    var outputs: ReceiptUploadSuccessViewModelOutput { return self }
    
    
    // MARK: - Init
    init() {
        
    }
}

