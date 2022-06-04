//
//  MoreBankDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 28/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import UIKit

protocol MoreBankDetailsViewModelInput {
    var settingsObserver: AnyObserver<Void> { get }
    var shareObserver: AnyObserver<Void> { get }
}

protocol MoreBankDetailsViewModelOutput {
    var profileImage: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var iban: Observable<String?> { get }
    var swift: Observable<String?> { get }
    var account: Observable<String?> { get }
    var bank: Observable<String?> { get }
    var address: Observable<String?> { get }
    var shareInfo: Observable<String> { get }
    var canShare: Observable<Bool> { get }
    var openProfile: Observable<Void> { get }
}

protocol MoreBankDetailsViewModelType {
    var inputs: MoreBankDetailsViewModelInput { get }
    var outputs: MoreBankDetailsViewModelOutput { get }
}

class MoreBankDetailsViewModel: MoreBankDetailsViewModelType, MoreBankDetailsViewModelInput, MoreBankDetailsViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    private var accountProvider: AccountProvider!
    var inputs: MoreBankDetailsViewModelInput { return self }
    var outputs: MoreBankDetailsViewModelOutput { return self }
    
    private let profileImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let ibanSubject = BehaviorSubject<String?>(value: nil)
    private let swiftSubject = BehaviorSubject<String?>(value: nil)
    private let accountSubject = BehaviorSubject<String?>(value: nil)
    private let bankSubject = BehaviorSubject<String?>(value: nil)
    private let addressSubject = BehaviorSubject<String?>(value: nil)
    private let shareObserverSubject = PublishSubject<Void>()
    private let shareInfoSubject = PublishSubject<String>()
    private let settingsSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var settingsObserver: AnyObserver<Void> { return settingsSubject.asObserver() }
    var shareObserver: AnyObserver<Void> { return shareObserverSubject.asObserver() }
    
    // MARK: - Outputs
    var profileImage: Observable<(String?, UIImage?)> { return profileImageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var iban: Observable<String?> { return ibanSubject.asObservable() }
    var swift: Observable<String?> { return swiftSubject.asObservable() }
    var address: Observable<String?> { return addressSubject.asObservable() }
    var bank: Observable<String?> { return bankSubject.asObservable() }
    var account: Observable<String?> { return accountSubject.asObservable() }
    var shareInfo: Observable<String> { return shareInfoSubject.asObservable() }
    var canShare: Observable<Bool> { self.accountProvider.currentAccount.map{ $0?.parnterBankStatus == .activated }.asObservable() }
    var openProfile: Observable<Void> { return settingsSubject.asObservable() }
    
    // MARK: - Init
    init(accountProvider: AccountProvider ) {
        self.accountProvider = accountProvider
        let account = self.accountProvider.currentAccount //SessionManager.current.currentAccount

        account.map { ($0?.customer.imageURL?.absoluteString, $0?.customer.fullName?.initialsImage(color: UIColor.red))}.bind(to: profileImageSubject).disposed(by: disposeBag)

        account.map { $0?.customer.fullName }.bind(to: nameSubject).disposed(by: disposeBag)
        
        
        account.map { account in return account?.iban?.removeWhitespace() }.bind(to: ibanSubject).disposed(by: disposeBag)
        
        
        account.map { $0?.customer.fullMobileNo }.bind(to: swiftSubject).disposed(by: disposeBag)
        account.map { $0?.bank?.name ?? "" }.bind(to: bankSubject).disposed(by: disposeBag)
        account.map { $0?.bank?.address ?? "" }.bind(to: addressSubject).disposed(by: disposeBag)
        account.map { account in account?.parnterBankStatus == .activated ? account?.accountNumber : account?.accountNumber }.bind(to: accountSubject).disposed(by: disposeBag)

        shareObserverSubject.withLatestFrom(account).unwrap().map {
            let iban = ($0.parnterBankStatus == .activated ? $0.formattedIBAN?.removeWhitespace() : $0.formattedIBAN?.removeWhitespace()) ?? ""
            let accountNumber = ($0.parnterBankStatus == .activated ? $0.accountNumber : $0.accountNumber) ?? ""
            return String.init(format: "Name: %@\nIBAN: %@\nAccount: %@", $0.customer.fullName ?? "", iban, accountNumber)
        }.bind(to: shareInfoSubject).disposed(by: disposeBag)
        
    }
}
