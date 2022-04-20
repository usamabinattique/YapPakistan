//
//  MenuItemTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import UIKit

protocol MenuItemTableViewCellViewModelInput {}

protocol MenuItemTableViewCellViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String?> { get }
    var iconColor: Observable<UIColor> { get }
}

protocol MenuItemTableViewCellViewModelType {
    var inputs: MenuItemTableViewCellViewModelInput { get }
    var outputs: MenuItemTableViewCellViewModelOutput { get }
}

class MenuItemTableViewCellViewModel: MenuItemTableViewCellViewModelType, ReusableTableViewCellViewModelType, MenuItemTableViewCellViewModelInput, MenuItemTableViewCellViewModelOutput {
    
    var reusableIdentifier: String { return MenuItemTableViewCell.defaultIdentifier }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MenuItemTableViewCellViewModelInput { return self }
    var outputs: MenuItemTableViewCellViewModelOutput { return self }
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let iconColorSubject = BehaviorSubject<UIColor>(value: .gray)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var iconColor: Observable<UIColor> { iconColorSubject.asObservable() }
    
    let menuItemType: MenuItemType
    
    // MARK: - Init
    init(menuItemType: MenuItemType) {
        self.menuItemType = menuItemType
        
        iconColorSubject.onNext(menuItemType.color!)
        iconSubject.onNext(menuItemType.icon)
        titleSubject.onNext(menuItemType.title)
    }
}
