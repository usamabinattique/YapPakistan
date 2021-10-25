//
//  WelcomeViewModel.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import RxSwift

protocol WelcomeViewModelInput {
    var personalObserver: AnyObserver<Void> { get }
    var businessObserver: AnyObserver<Void> { get }
    var signInObserver: AnyObserver<Void> { get }
}

protocol WelcomeViewModelOutput {
    var personal: Observable<Void> { get }
    var business: Observable<Void> { get }
    var signIn: Observable<Void> { get }
}

protocol WelcomeViewModelType {
    var inputs: WelcomeViewModelInput { get }
    var outputs: WelcomeViewModelOutput { get }
}

class WelcomeViewModel: WelcomeViewModelInput, WelcomeViewModelOutput, WelcomeViewModelType {

    var inputs: WelcomeViewModelInput { return self }
    var outputs: WelcomeViewModelOutput { return self }

    private let personalSubject = PublishSubject<Void>()
    private let businessSubject = PublishSubject<Void>()
    private let signInSubject = PublishSubject<Void>()

    // inputs
    var personalObserver: AnyObserver<Void> { return personalSubject.asObserver() }
    var businessObserver: AnyObserver<Void> { return businessSubject.asObserver() }
    var signInObserver: AnyObserver<Void> { return signInSubject.asObserver() }

    // outputs
    var personal: Observable<Void> { return personalSubject.asObservable() }
    var business: Observable<Void> { return businessSubject.asObservable() }
    var signIn: Observable<Void> { return signInSubject.asObservable() }

}
