//
//  MenuUserTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol MenuUserTableViewCellViewModelInput {
    var dropDownObserver: AnyObserver<Void> { get }
}

protocol MenuUserTableViewCellViewModelOutput {
    var packageType: Observable<String?> { get }
    var name: Observable<String?> { get }
    var accountNumber: Observable<String?> { get }
    var iban: Observable<String?> { get }
    var dropDown: Observable<Void> { get }
    var dropDownState: Observable<DropDownButton.ButtonState> { get }
    var package: Observable<UIImage?> { get }
    var isFounder: Observable<Bool> { get }
}

protocol MenuUserTableViewCellViewModelType {
    var inputs: MenuUserTableViewCellViewModelInput { get }
    var outputs: MenuUserTableViewCellViewModelOutput { get }
}

class MenuUserTableViewCellViewModel: MenuUserTableViewCellViewModelType, ReusableTableViewCellViewModelType, MenuUserTableViewCellViewModelInput, MenuUserTableViewCellViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MenuUserTableViewCellViewModelInput { return self }
    var outputs: MenuUserTableViewCellViewModelOutput { return self }
    
    private let dropDownSubject = PublishSubject<Void>()
    private let dropDownStateSubject = BehaviorSubject<DropDownButton.ButtonState>(value: .down)
    private let packageTypeSubject = BehaviorSubject<String?>(value: "")
    private let nameSubject = BehaviorSubject<String?>(value: "")
    private let accountNumberSubject = BehaviorSubject<String?>(value: "")
    private let ibanSubject = BehaviorSubject<String?>(value: "")
    private let packageSubject = BehaviorSubject<UIImage?>(value: PaymentCardPlan.spare.badge)
    private let isFounderSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    var dropDownObserver: AnyObserver<Void> { return dropDownSubject.asObserver() }
    
    // MARK: - Outputs
    var packageType: Observable<String?> { return packageTypeSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var accountNumber: Observable<String?> { return accountNumberSubject.asObservable() }
    var iban: Observable<String?> { return ibanSubject.asObservable() }
    var dropDown: Observable<Void> { return dropDownSubject.asObservable() }
    var dropDownState: Observable<DropDownButton.ButtonState> { return dropDownStateSubject.asObservable() }
    var package: Observable<UIImage?> { packageSubject.asObservable() }
    var isFounder: Observable<Bool> { isFounderSubject.asObservable() }
    
    var reusableIdentifier: String { return MenuUserTableViewCell.defaultIdentifier }
    
    init(accountProvider: AccountProvider) {
        
        let account = accountProvider.currentAccount
        account.map { $0?.customer.fullName }.bind(to: nameSubject).disposed(by: disposeBag)
        account.map { $0?.accountNumber }.bind(to: accountNumberSubject).disposed(by: disposeBag)
        account.map { $0?.formattedIBAN }.bind(to: ibanSubject).disposed(by: disposeBag)
        account.map{ $0?.customer.isFounder ?? false }.bind(to: isFounderSubject).disposed(by: disposeBag)
        
        dropDownSubject.withLatestFrom(dropDownStateSubject).map { $0 == .down ? .up : .down }.bind(to: dropDownStateSubject).disposed(by: disposeBag)
        
//        CardsManager.shared.cards.map { (cards) -> String? in
//            var plan: String? = nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.spare }.count>0 ? PaymentCardPlan.spare.rawValue:nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.premium }.count>0 ? PaymentCardPlan.premium.rawValue:nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.metal }.count>0 ? PaymentCardPlan.metal.rawValue:nil
//            return plan
//        }.bind(to: packageTypeSubject).disposed(by: disposeBag)
//
//        CardsManager.shared.cards.map { (cards) -> UIImage? in
//            var plan: UIImage? = nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.spare }.count>0 ? PaymentCardPlan.spare.badge:nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.premium }.count>0 ? PaymentCardPlan.premium.badge:nil
//            plan = cards.filter { $0.cardPlan == PaymentCardPlan.metal }.count>0 ? PaymentCardPlan.metal.badge:nil
//            return plan ?? PaymentCardPlan.spare.badge
//        }.bind(to: packageSubject).disposed(by: disposeBag)
        
    }
    
}
