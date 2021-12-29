//
//  BottomLoadingTableViewCellViewModel.swift
//  YAPKit
//
//  Created by Zain on 24/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol BottomLoadingTableViewCellViewModelInput {
    
}

protocol BottomLoadingTableViewCellViewModelOutput {
    var indicatorStyle: Observable<UIActivityIndicatorView.Style> { get }
}

protocol BottomLoadingTableViewCellViewModelType {
    var inputs: BottomLoadingTableViewCellViewModelInput { get }
    var outputs: BottomLoadingTableViewCellViewModelOutput { get }
}

class BottomLoadingTableViewCellViewModel: BottomLoadingTableViewCellViewModelType,
                                           BottomLoadingTableViewCellViewModelInput,
                                           BottomLoadingTableViewCellViewModelOutput,
                                           ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: BottomLoadingTableViewCellViewModelInput { return self }
    var outputs: BottomLoadingTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return BottomLoadingTableViewCell.defaultIdentifier }
    
    private let indicatorStyleSubject: BehaviorSubject<UIActivityIndicatorView.Style>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var indicatorStyle: Observable<UIActivityIndicatorView.Style> { return indicatorStyleSubject.asObservable() }
    
    // MARK: - Init
    init(_ style: UIActivityIndicatorView.Style = .gray) {
        indicatorStyleSubject = BehaviorSubject<UIActivityIndicatorView.Style>(value: style)
    }
}
