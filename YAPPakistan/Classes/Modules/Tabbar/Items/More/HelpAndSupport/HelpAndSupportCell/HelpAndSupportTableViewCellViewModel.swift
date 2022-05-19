//
//  HelpAndSupportTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol HelpAndSupportTableViewCellViewModelInput {
    
}

protocol HelpAndSupportTableViewCellViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String?> { get }
}

protocol HelpAndSupportTableViewCellViewModelType {
    var inputs: HelpAndSupportTableViewCellViewModelInput { get }
    var outputs: HelpAndSupportTableViewCellViewModelOutput { get }
}

class HelpAndSupportTableViewCellViewModel: HelpAndSupportTableViewCellViewModelType, HelpAndSupportTableViewCellViewModelInput, HelpAndSupportTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: HelpAndSupportTableViewCellViewModelInput { return self }
    var outputs: HelpAndSupportTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return HelpAndSupportTableViewCell.defaultIdentifier }
    let action: HelpAndSupportActionType!
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    
    // MARK: - Init
    init(_ action: HelpAndSupportActionType) {
        self.action = action
        
        iconSubject.onNext(action.icon)
        titleSubject.onNext(action.title)
    }
}
