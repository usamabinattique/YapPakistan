//
//  AccountProvider.swift
//  YAPKit
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class AccountProvider {
    private let repository: AccountRepositoryType
    private let disposeBag = DisposeBag()

    private let accountsSubject = BehaviorSubject<[Account]>(value: [])
    private let updatingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<String>()

    private var accountSubject: BehaviorSubject<Account?> = BehaviorSubject<Account?>(value: nil)
    private var currentAccountInput: AnyObserver<Account?> { accountSubject.asObserver() }

    public var currentAccount: Observable<Account?> { accountSubject.asObservable() }
    
    public let currentAccountValue: BehaviorRelay<Account?> = BehaviorRelay(value: nil)

    public init(repository: AccountRepositoryType) {
        self.repository = repository
        accountSubject.bind(to: currentAccountValue).disposed(by: disposeBag)
        refreshAccount()
    }

    public func refreshAccount() -> Observable<Void> {
        updatingSubject.onNext(true)

        let request = self.repository.fetchAccounts().share()

        request.elements().subscribe(onNext: { [unowned self] userAccounts in
            self.accountsSubject.onNext(userAccounts)

            if var currentAccount = userAccounts.first {
                // po currentAccount._accountStatus = "ADDRESS_PENDING"
                self.accountSubject.onNext(currentAccount)
            }
        }).disposed(by: disposeBag)

        request.errors().subscribe(onNext: { [unowned self] error in
            self.accountsSubject.onNext([])
            self.errorSubject.onNext(error.localizedDescription)
        }).disposed(by: disposeBag)

        return request.map { _ in }
    }
}
