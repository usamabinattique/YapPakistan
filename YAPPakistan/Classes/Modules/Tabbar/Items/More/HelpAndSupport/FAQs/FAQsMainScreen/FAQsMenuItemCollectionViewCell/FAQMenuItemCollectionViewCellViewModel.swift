//
//  FAQMenuItemCollectionViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import Foundation
import RxSwift

protocol FAQMenuItemCollectionViewCellViewModelInput {
    
}

protocol FAQMenuItemCollectionViewCellViewModelOutput {
    var menuTitle: Observable<String?> { get }
    var isSelected: Observable<Bool?> { get }
}

protocol FAQMenuItemCollectionViewCellViewModelType {
    var inputs: FAQMenuItemCollectionViewCellViewModelInput { get }
    var outputs: FAQMenuItemCollectionViewCellViewModelOutput { get }
}

class FAQMenuItemCollectionViewCellViewModel: FAQMenuItemCollectionViewCellViewModelType, FAQMenuItemCollectionViewCellViewModelInput, FAQMenuItemCollectionViewCellViewModelOutput, ReusableCollectionViewCellViewModelType {
    
    var inputs: FAQMenuItemCollectionViewCellViewModelInput { return self }
    var outputs: FAQMenuItemCollectionViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return FAQMenuItemCollectionViewCell.defaultIdentifier }
    
    public var titleSubject = BehaviorSubject<String?>(value: nil)
    public var isSelectedSubject = BehaviorSubject<Bool?>(value: false)
    
    // MARK: Outputs
    var menuTitle: Observable<String?> { return titleSubject.asObservable() }
    var isSelected: Observable<Bool?> { return isSelectedSubject.asObservable() }
    
    
    init(title : String, isSelected : Bool) {
        titleSubject = BehaviorSubject(value: title)
        isSelectedSubject = BehaviorSubject(value: isSelected)
    }
    
}
