//
//  YAPActionSheetTableViewCellViewModel.swift
//  YAPKit
//
//  Created by Zain on 03/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Outputs Protocol

protocol YAPActionSheetTableViewCellViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String?> { get }
    var subtitle: Observable<String?> { get }
}

// MARK: - Inputs/Outputs Protocol

protocol YAPActionSheetTableViewCellViewModelType {
    var outputs: YAPActionSheetTableViewCellViewModelOutput { get }
}

// MARK: - View Model

class YAPActionSheetTableViewCellViewModel: YAPActionSheetTableViewCellViewModelType, YAPActionSheetTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    // MARK: - Properties

    let disposeBag = DisposeBag()
    var outputs: YAPActionSheetTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return YAPActionSheetTableViewCell.defaultIdentifier }
    let action: YAPActionSheetAction!
    
    // MARK: - Subjects

    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let subtitleSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Outputs

    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var subtitle: Observable<String?> { return subtitleSubject.asObservable() }
    
    // MARK: - Init

    init(action: YAPActionSheetAction) {
        self.action = action
        iconSubject.onNext(action.image)
        titleSubject.onNext(action.title)
        subtitleSubject.onNext(action.subtitle)
    }
}
