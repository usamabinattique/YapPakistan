//
//  FAQsTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 18/05/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol FAQsTableViewCellViewModelInput {
    
}

protocol FAQsTableViewCellViewModelOutput {
    //var icon: Observable<UIImage?> { get }
    var question: Observable<String?> { get }
}

protocol FAQsTableViewCellViewModelType {
    var inputs: FAQsTableViewCellViewModelInput { get }
    var outputs: FAQsTableViewCellViewModelOutput { get }
}

class FAQsTableViewCellViewModel: FAQsTableViewCellViewModelType, FAQsTableViewCellViewModelInput, FAQsTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: FAQsTableViewCellViewModelInput { return self }
    var outputs: FAQsTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return FAQsTableViewCell.defaultIdentifier }
    //let action: HelpAndSupportActionType!
    
    //private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let questionSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    //var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var question: Observable<String?> { return questionSubject.asObservable() }
    
    // MARK: - Init
    init(faq: FAQsResponse) {
        //self.action = action
        
        //iconSubject.onNext(action.icon)
        questionSubject.onNext(faq.question)
    }
}
