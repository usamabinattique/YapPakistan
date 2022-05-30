//
//  TDReceiptCollectionViewCellViewModel.swift
//  Cards
//
//  Created by Janbaz Ali on 26/10/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

protocol TDReceiptCollectionViewCellViewModelInputs {
    
}

protocol TDReceiptCollectionViewCellViewModelOutputs {
    var title: Observable<String> { get }
}

protocol TDReceiptCollectionViewCellViewModelType {
    var inputs: TDReceiptCollectionViewCellViewModelInputs { get }
    var outputs: TDReceiptCollectionViewCellViewModelOutputs { get }
}

class TDReceiptCollectionViewCellViewModel: TDReceiptCollectionViewCellViewModelType, TDReceiptCollectionViewCellViewModelInputs, TDReceiptCollectionViewCellViewModelOutputs, ReusableCollectionViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var reusableIdentifier: String { return TDReceiptCollectionViewCell.defaultIdentifier }
    
    var inputs: TDReceiptCollectionViewCellViewModelInputs { return self}
    var outputs: TDReceiptCollectionViewCellViewModelOutputs { return self }
    
    private let titleSubject = BehaviorSubject<String>(value: "")
    
    // MARK: - inputs
    
    // MARK: - outputs
    var title: Observable<String> { return titleSubject.asObservable() }
    
    init(title: String) {
        titleSubject.onNext(title)
    }
}
