//
//  SplashViewModel.swift
//  YapPakistanApp
//
//  Created by Sarmad on 24/08/2021.
//

import Foundation
import RxSwift
import RxSwiftExt
import YAPCore

enum NavigationType {
    case login
    case passcode
    case onboarding
}

protocol SplashViewModelInput {
    var refreshXSRF: AnyObserver<Void> { get }
    var animationCompleteObserver: AnyObserver<Void> { get }
}

protocol SplashViewModelOutput {
    var xsrfSuccess: Observable<NavigationType> { get }
    var showError: Observable<String> { get }
    var showAnimation:Observable<Void> { get }
    var next: Observable<NavigationType> { get }
}

protocol SplashViewModelType {
    var inputs: SplashViewModelInput { get }
    var outputs: SplashViewModelOutput { get }
}

struct AppSettings {
    static var isAppRunFirstTime = false
}

class SplashViewModel: SplashViewModelInput, SplashViewModelOutput, SplashViewModelType {
    var inputs: SplashViewModelInput { return self }
    var outputs: SplashViewModelOutput { return self }
    
    private let xsrfSuccessSubject = PublishSubject<NavigationType>()
    private let showErrorSubject = PublishSubject<String>()
    private let showAnimationSubject = PublishSubject<Void>()
    private let refreshRequestSubject = PublishSubject<Void>()
    private let nextSubject = PublishSubject<NavigationType>()
    private let animationCompleteSubject = PublishSubject<Void>()
    
    // Input
    var refreshXSRF: AnyObserver<Void> { return refreshRequestSubject.asObserver() }
    var animationCompleteObserver: AnyObserver<Void> { animationCompleteSubject.asObserver() }
    
    // Outputs
    var xsrfSuccess: Observable<NavigationType> { return xsrfSuccessSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var showAnimation: Observable<Void> { return showAnimationSubject.asObservable() }
    var next: Observable<NavigationType> { return nextSubject.asObservable() }
    
    private let disposeBag = DisposeBag()
    private let credentialsStore: CredentialsStoreType
    
    init(shortcutItem: UIApplicationShortcutItem?,
         credentialsStore: CredentialsStoreType) {
        self.credentialsStore = credentialsStore
        bindNextNavigation()
    }
    
    private func bindNextNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAnimationSubject.onNext(())
        }
        animationCompleteSubject.subscribe(onNext: { [weak self] in
            self?.nextSubject.onNext(NavigationType.onboarding)
            self?.nextSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    private var xsrf: String? { HTTPCookieStorage.shared.cookies?.filter { $0.name == "XSRF-TOKEN" }.first?.value   }
    
}
