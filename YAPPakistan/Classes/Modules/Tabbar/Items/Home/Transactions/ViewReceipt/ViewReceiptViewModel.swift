//
//  ViewReceiptViewModel.swift
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

protocol ViewReceiptViewModelInput {
    var backObserver: AnyObserver<Void> { get }

}

protocol ViewReceiptViewModelOutput {
    var back: Observable<Void> { get }
    
}

protocol ViewReceiptViewModelType {
    var inputs: ViewReceiptViewModelInput { get }
    var outputs: ViewReceiptViewModelOutput { get }
}

class ViewReceiptViewModel: ViewReceiptViewModelType, ViewReceiptViewModelInput, ViewReceiptViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ViewReceiptViewModelInput { return self }
    var outputs: ViewReceiptViewModelOutput { return self }
    var imageURL : String!
    
    // MARK: Subjects
    var backSubject = PublishSubject<Void>()
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    
    //MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    
    // MARK: - Init
    init(imageURL: String) {
        self.imageURL = imageURL
    }
    
}

