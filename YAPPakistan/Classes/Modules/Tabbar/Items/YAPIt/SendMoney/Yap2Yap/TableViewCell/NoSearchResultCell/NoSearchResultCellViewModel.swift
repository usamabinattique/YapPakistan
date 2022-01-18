//
//  NoSearchResultCellViewModel.swift
//  YAP
//
//  Created by Zain on 10/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol NoSearchResultCellViewModelInput {
    
}

protocol NoSearchResultCellViewModelOutput {
    var title: Observable<String?> { get }
}

protocol NoSearchResultCellViewModelType {
    var inputs: NoSearchResultCellViewModelInput { get }
    var outputs: NoSearchResultCellViewModelOutput { get }
}

open class NoSearchResultCellViewModel: NoSearchResultCellViewModelType, NoSearchResultCellViewModelInput, NoSearchResultCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: NoSearchResultCellViewModelInput { return self }
    var outputs: NoSearchResultCellViewModelOutput { return self }
    open var reusableIdentifier: String { return NoSearchResultCell.defaultIdentifier }
    
    private let titleSubject: BehaviorSubject<String?>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var title: Observable<String?> { titleSubject.asObservable() }
    
    // MARK: - Init
    public init(title: String = "No results") {
        titleSubject = BehaviorSubject(value: title)
    }
}
