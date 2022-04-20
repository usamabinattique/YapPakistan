//
//  UserAccountTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 26/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol UserAccountTableViewCellViewModelInput {
}

protocol UserAccountTableViewCellViewModelOutput {
    var userImage: Observable<(URL?, UIImage?)> { get }
    var isCurrent: Observable<(current: Bool, accountType: AccountType)> { get }
    var title: Observable<String> { get }
}

protocol UserAccountTableViewCellViewModelType {
    var inputs: UserAccountTableViewCellViewModelInput { get }
    var outputs: UserAccountTableViewCellViewModelOutput { get }
}

class UserAccountTableViewCellViewModel: UserAccountTableViewCellViewModelType, ReusableTableViewCellViewModelType, UserAccountTableViewCellViewModelInput, UserAccountTableViewCellViewModelOutput {
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: UserAccountTableViewCellViewModelInput { self }
    var outputs: UserAccountTableViewCellViewModelOutput { self }
    
    private var userImageSubject = BehaviorSubject<(URL?, UIImage?)>(value: (nil, nil))
    private let isCurrentSubject = BehaviorSubject<(current: Bool, accountType: AccountType)>(value: (false, .b2cAccount))
    private let titleSubject = BehaviorSubject<String>(value: "screen_menu_display_text_my_profile".localized)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var userImage: Observable<(URL?, UIImage?)> { userImageSubject.asObservable() }
    var isCurrent: Observable<(current: Bool, accountType: AccountType)> { isCurrentSubject.asObservable() }
    var title: Observable<String> { return titleSubject.asObservable() }
    
    let account: Account
    var reusableIdentifier: String { return UserAccountTableViewCell.defaultIdentifier }
    
    // MARK: - Init
    init(account: Account, accountProvider: AccountProvider) {
        self.account = account
        
        userImageSubject.onNext((account.customer.imageURL, account.customer.fullName?.initialsImage(color: account.customer.accentColor)))
        
        titleSubject.onNext("screen_menu_display_text_my_profile".localized)
    }
}
