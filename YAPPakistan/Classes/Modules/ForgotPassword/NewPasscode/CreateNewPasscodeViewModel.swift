//
//  CreateNewPasscodeViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/09/2021.
//

import Foundation
import RxSwift
import YAPCore

class CreateNewPasscodeViewModel: PasscodeViewModel {

    var repository: PINRepositoryType
    var credentialsManager:CredentialsStoreType
    var username: String
    var token: String

    init(repository: PINRepositoryType,
         credentialsManager: CredentialsStoreType,
         username: String,
         token: String,
         passcodeViewStrings: PasscodeViewStrings,
         pinRange: ClosedRange<Int>
    ) {
        self.repository = repository
        self.credentialsManager = credentialsManager
        self.username = username
        self.token = token

        super.init(pinRange: pinRange, localizeableKeys: passcodeViewStrings)

        let changePasscodeRequest = actionSubject.withLatestFrom(pinTextSubject).unwrap().withUnretained(self)
            .do(onNext: { $0.0.loaderSubject.onNext(true) })
            .flatMapLatest{ repository.newPassword(username: $0.0.username, token: $0.0.token, password: $0.1) }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        changePasscodeRequest.errors()
            .map { $0.localizedDescription }
            .bind(to: errorSubject).disposed(by: disposeBag)

        changePasscodeRequest.elements()
            .map { _ in "" }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)

        changePasscodeRequest.elements()
            .withLatestFrom(pinTextSubject.unwrap())
            .withUnretained(self)
            .do(onNext: { `self`, passcode in
                self.credentialsManager.secureCredentials(username: self.username, passcode: passcode)
            }).subscribe().disposed(by: disposeBag)
    }
}
