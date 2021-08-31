//
//  SplashViewModel.swift
//  YapPakistanApp
//
//  Created by Sarmad on 24/08/2021.
//

import Foundation
import RxSwift

enum NavigationType {
    case login(xsrfToken: String)
    case passcode(xsrfToken: String)
    case onboarding(xsrfToken: String)
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
    //private var repository: SplashRepositoryType
    //private let credentialsStore: CredentialsStoreType
    
    init() { }
    /*init(shortcutItem: UIApplicationShortcutItem?,
         credentialsStore: CredentialsStoreType,
         repository: SplashRepositoryType) {
        self.credentialsStore = credentialsStore
        self.repository = repository
        bindNextNavigation()
        fetchXSRF(repository: repository)
    }*/
    
    /*
    private func fetchXSRF(repository: SplashRepositoryType) {
        let xsrfRequest = refreshRequestSubject.startWith(()).flatMap {
            repository.fetchXSRFToken()
        }.share(replay: 1, scope: .whileConnected)
        // Success
        xsrfRequest.elements().subscribe(onNext: { [unowned self] _ in
            if let token = xsrf {
                if AppSettings.isAppRunFirstTime {
                    self.xsrfSuccessSubject.onNext(.onboarding(xsrfToken: token))
                    AppSettings.isAppRunFirstTime = false
                } else {
                    let result = self.credentialsStore.isCredentialsAvailable ? .passcode(xsrfToken: token) : NavigationType.login(xsrfToken: token)
                    self.xsrfSuccessSubject.onNext(result)
                }
            }
        }).disposed(by: disposeBag)
        // Error
        xsrfRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
    }
    */
    private func bindNextNavigation() {
        xsrfSuccessSubject.map { _ in }.bind(to: showAnimationSubject).disposed(by: disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAnimationSubject.onNext(())
        }
        animationCompleteSubject.withLatestFrom(xsrfSuccessSubject).subscribe(onNext: { [weak self] in
            self?.nextSubject.onNext($0)
            self?.nextSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    private var xsrf: String? { HTTPCookieStorage.shared.cookies?.filter { $0.name == "XSRF-TOKEN" }.first?.value   }
    
}
