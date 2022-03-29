//
//  TopUpAccountDetailsUserCellViewModel.swift
//  YAP
//
//  Created by Zain on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol TopUpAccountDetailsUserCellViewModelInput {
    
}

protocol TopUpAccountDetailsUserCellViewModelOutput {
//    var userImage: Observable<(String?, UIImage?)> { get }
}

protocol TopUpAccountDetailsUserCellViewModelType {
    var inputs: TopUpAccountDetailsUserCellViewModelInput { get }
    var outputs: TopUpAccountDetailsUserCellViewModelOutput { get }
}

class TopUpAccountDetailsUserCellViewModel: TopUpAccountDetailsUserCellViewModelType, TopUpAccountDetailsUserCellViewModelInput, TopUpAccountDetailsUserCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopUpAccountDetailsUserCellViewModelInput { return self }
    var outputs: TopUpAccountDetailsUserCellViewModelOutput { return self }
    var reusableIdentifier: String { TopUpAccountDetailsUserCell.defaultIdentifier }
    
//    private let userImageSubject: BehaviorSubject<(String?, UIImage?)>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
//    var userImage: Observable<(String?, UIImage?)> { userImageSubject.asObservable() }
    
    // MARK: - Init
    init(userImage: (String?, UIImage?)) {
//        userImageSubject = BehaviorSubject<(String?, UIImage?)>(value: userImage)
    }
}

