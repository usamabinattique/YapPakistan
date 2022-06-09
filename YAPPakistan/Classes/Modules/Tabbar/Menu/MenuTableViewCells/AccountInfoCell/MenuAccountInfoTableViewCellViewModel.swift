//
//  MenuAccountInfoTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol MenuAccountInfoTableViewCellViewModelInput {
    var showInfoObserver: AnyObserver<Bool> { get }
    var shareObserver: AnyObserver<Void> { get }
}

protocol MenuAccountInfoTableViewCellViewModelOutput {
    var showInfo: Observable<Bool> { get }
    var accountNumber: Observable<String?> { get }
    var iban: Observable<String?> { get }
//    var showsShareButton: Observable<Bool> { get }
    var shareAccountInfo: Observable<String> { get }
}

protocol MenuAccountInfoTableViewCellViewModelType {
    var inputs: MenuAccountInfoTableViewCellViewModelInput { get }
    var outputs: MenuAccountInfoTableViewCellViewModelOutput { get }
}

class MenuAccountInfoTableViewCellViewModel: MenuAccountInfoTableViewCellViewModelType, ReusableTableViewCellViewModelType, MenuAccountInfoTableViewCellViewModelInput, MenuAccountInfoTableViewCellViewModelOutput {
    
    var reusableIdentifier: String { return MenuAccountInfoTableViewCell.defaultIdentifier }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MenuAccountInfoTableViewCellViewModelInput { return self }
    var outputs: MenuAccountInfoTableViewCellViewModelOutput { return self }
    private var accountProvider: AccountProvider!
    
    private let showInfoSubject = PublishSubject<Bool>()
    private let accountNumberSubject = BehaviorSubject<String?>(value: "")
    private let ibanSubject = BehaviorSubject<String?>(value: "")
    private let shareSubject = PublishSubject<Void>()
    private let shareAccountInfoSubject = PublishSubject<String>()
    
    // MARK: - Inputs
    var showInfoObserver: AnyObserver<Bool> { return showInfoSubject.asObserver() }
    var shareObserver: AnyObserver<Void> { return shareSubject.asObserver() }
    
    // MARK: - Outputs
    var showInfo: Observable<Bool> { return showInfoSubject.asObservable() }
    var accountNumber: Observable<String?> { return accountNumberSubject.asObservable() }
    var iban: Observable<String?> { return ibanSubject.asObservable() }
    var showsShareButton: Observable<Bool> { return
        self.accountProvider.currentAccount.map{ $0?.parnterBankStatus == .activated }.asObservable() }
    var shareAccountInfo: Observable<String> { return shareAccountInfoSubject.asObservable() }
    
    // MARK: - Init
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
        let account = self.accountProvider.currentAccount
        account.map { $0?.accountNumber /*$0?.parnterBankStatus == .activated ? $0?.accountNumber : $0?.maskedAccountNumber*/ }.bind(to: accountNumberSubject).disposed(by: disposeBag)
        account.map { account in account?.iban /*(account?.parnterBankStatus == .activated ? account?.formattedIBAN : account?.maskedAndFormattedIBAN)*/ }.bind(to: ibanSubject).disposed(by: disposeBag)

        shareSubject.withLatestFrom(account).unwrap().subscribe(onNext: { [ unowned self ] account in
            
            let iban = account.formattedIBAN ?? ""//(account.parnterBankStatus == .activated ? account.formattedIBAN : account.maskedAndFormattedIBAN) ?? ""
            let accountNumber = account.accountNumber ?? ""//(account.parnterBankStatus == .activated ? account.accountNumber : account.maskedAccountNumber) ?? ""
            let accountInfo = "Account Number: " + accountNumber + "\nIBAN: " + iban
          //  UIPasteboard.general.string = "Account Number: " + accountNumber + "\nIBAN: " + iban
            //YAPToast.show("Copied to clipboard")
            self.shareAccountInfoSubject.onNext(accountInfo)
        }).disposed(by: disposeBag)
    }
    
}
