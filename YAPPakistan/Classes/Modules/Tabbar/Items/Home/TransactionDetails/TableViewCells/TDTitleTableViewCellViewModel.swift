//
//  TDTitleTableViewCellViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 28/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

protocol TDTitleTableViewCellViewModelOutputs {
    var title: Observable<String?> { get }
}

protocol TDTitleTableViewCellViewModelType {
    var outputs: TDTitleTableViewCellViewModelOutputs { get }
}

class TDTitleTableViewCellViewModel: TDTitleTableViewCellViewModelType, TDTitleTableViewCellViewModelOutputs, ReusableTableViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDTitleTableViewCell.defaultIdentifier }
    
    var outputs: TDTitleTableViewCellViewModelOutputs { return self }
    
    private let titleSubject: BehaviorSubject<String?>
    
    // MARK: - Outputs
    var title: Observable<String?> { return titleSubject.asObservable() }
    
    init(title: String) {
        titleSubject = BehaviorSubject(value: title)
    }
    
}
