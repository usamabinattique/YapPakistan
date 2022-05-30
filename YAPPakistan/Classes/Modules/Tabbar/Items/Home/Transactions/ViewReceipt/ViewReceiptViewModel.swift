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
    var deleteObserver: AnyObserver<Void> { get }

}

protocol ViewReceiptViewModelOutput {
    var back: Observable<Void> { get }
    var loadImage: Observable<String> { get }
    
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
    var transactionID : String
    
    // MARK: Subjects
    var backSubject = PublishSubject<Void>()
    var deleteSubject = PublishSubject<Void>()
    var loadImageSubject = BehaviorSubject<String>(value: "") //PublishSubject<String>()
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var deleteObserver: AnyObserver<Void> { deleteSubject.asObserver() }
    
    //MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var loadImage: Observable<String> { return loadImageSubject.asObservable() }
    
    // MARK: - Init
    init(imageURL: String, transcationID: String) {
        self.imageURL = imageURL
        self.transactionID = transcationID
        self.loadImageSubject.onNext(imageURL)
    }
}

