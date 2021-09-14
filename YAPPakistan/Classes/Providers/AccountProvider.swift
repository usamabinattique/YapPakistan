//
//  AccountProvider.swift
//  YAPKit
//
//  Created by Umer on 25/06/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift

public class AccountProvider {
    private let repository: AccountRepositoryType
    private let disposeBag = DisposeBag()

    private var accountSubject: BehaviorSubject<Account?> = BehaviorSubject<Account?>(value: nil)
    private var currentAccountInput: AnyObserver<Account?> { accountSubject.asObserver() }

    public var currentAccount: Observable<Account?> { accountSubject.asObservable() }

    public init(repository: AccountRepositoryType) {
        self.repository = repository
        refreshAccount()
    }

    public func refreshAccount() {
        self.repository.fetchAccounts().dematerialize()
            .map { $0.first }
            .subscribe(onNext: { [unowned self] account in
                self.accountSubject.onNext(account)
            })
            .disposed(by: disposeBag)
    }
}
