//
//  DocumentMissingHeaderCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/06/2022.
//

import Foundation
import RxSwift
import YAPComponents

public protocol DocumentMissingHeaderCellViewModelInputs {
    
}

public protocol DocumentMissingHeaderCellViewModelOutputs {
    var title: Observable<String> { get }
}

public protocol DocumentMissingHeaderCellViewModelType {
    var inputs: DocumentMissingHeaderCellViewModelInputs { get }
    var outputs: DocumentMissingHeaderCellViewModelOutputs { get }
}

class DocumentMissingHeaderCellViewModel: DocumentMissingHeaderCellViewModelType,
                                          DocumentMissingHeaderCellViewModelInputs,
                                          DocumentMissingHeaderCellViewModelOutputs,
                                               ReusableTableViewCellViewModelType {
    
    let disposeBag = DisposeBag()
    var inputs: DocumentMissingHeaderCellViewModelInputs { return self}
    var outputs: DocumentMissingHeaderCellViewModelOutputs { return self }
    var reusableIdentifier: String { return DocumentMissingHeaderCell.defaultIdentifier }
    
    private let titleSubject: BehaviorSubject<String>
   
    
    // MARK: - inputs
    
    // MARK: - output
    var title: Observable<String> { titleSubject.asObservable() }
    
    
    
    init(title: String) {
        titleSubject = BehaviorSubject(value: title)
    }
    
}
