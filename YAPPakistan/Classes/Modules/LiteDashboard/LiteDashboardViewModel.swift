//
//  LiteDashboardViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

protocol LiteDashboardViewModelInputs {
    var resultObserver: AnyObserver<Void> { get }
    var logoutObserver: AnyObserver<Void> { get }
    var biometryChangeObserver: AnyObserver<Bool> { get }
    var completeVerificationObserver: AnyObserver<Void> { get }
    var viewAppearObserver: AnyObserver<Void> { get }
}

protocol LiteDashboardViewModelOutputs {
    var result: Observable<Void> { get }
    var logout: Observable<Void> { get }
    var biometry: Observable<Bool> { get }
    var biometrySupported: Observable<Bool> { get }
    var biometryTitle: Observable<String?> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var showActivity: Observable<Bool> { get }
    var headingText: Observable<String> { get }
    var logOutButtonTitle: Observable<String> { get }
    var completeVerificationHidden: Observable<Bool> { get }
    var completeVerification: Observable<Bool> { get }
}

protocol LiteDashboardViewModelType {
    var inputs: LiteDashboardViewModelInputs { get }
    var outputs: LiteDashboardViewModelOutputs { get }
}

class LiteDashboardViewModel: LiteDashboardViewModelType, LiteDashboardViewModelInputs, LiteDashboardViewModelOutputs {
    private let disposeBag = DisposeBag()

    private var resultSubject = PublishSubject<Void>()
    private var logoutSubject = PublishSubject<Void>()
    private var biometrySuject: BehaviorSubject<Bool>
    private var biometrySupportedSuject = BehaviorSubject<Bool>(value: false)
    private var biometryTitleSuject = BehaviorSubject<String?>(value: nil)
    private let errorSubject = PublishSubject<String>()
    private let loadingSubject = PublishSubject<Bool>()
    private var biometryChangeSuject = PublishSubject<Bool>()
    private let showActivitySubject = BehaviorSubject<Bool>(value: false)
    private let completeVerificationHiddenSubject = BehaviorSubject<Bool>(value: true)
    private let completeVerificationSubject = PublishSubject<Void>()
    private let completeVerificationResultSubject = PublishSubject<Bool>()
    private let viewAppearSubject = PublishSubject<Void>()

    var inputs: LiteDashboardViewModelInputs { return self }
    var outputs: LiteDashboardViewModelOutputs { return self }

    // MARK: Inputs

    var resultObserver: AnyObserver<Void> { resultSubject.asObserver() }
    var logoutObserver: AnyObserver<Void> { logoutSubject.asObserver() }
    var biometryChangeObserver: AnyObserver<Bool> { biometryChangeSuject.asObserver() }
    var completeVerificationObserver: AnyObserver<Void> { completeVerificationSubject.asObserver() }
    var viewAppearObserver: AnyObserver<Void> { viewAppearSubject.asObserver() }

    // MARK: Outputs

    var result: Observable<Void> { resultSubject.asObservable() }
    var logout: Observable<Void> { logoutSubject.asObservable() }
    var biometry: Observable<Bool> { biometrySuject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var biometrySupported: Observable<Bool> { biometrySupportedSuject.asObservable() }
    var biometryTitle: Observable<String?> { biometryTitleSuject.asObservable() }
    var showActivity: Observable<Bool> { showActivitySubject.asObservable() }
    var headingText: Observable<String> { Observable.of("screen_light_dashboard_display_text_heading_text".localized) }
    var logOutButtonTitle: Observable<String> { Observable.of("screen_light_dashboard_button_logout".localized) }
    var completeVerificationHidden: Observable<Bool> { completeVerificationHiddenSubject.asObservable() }
    var completeVerification: Observable<Bool> { completeVerificationResultSubject.asObserver() }

    // MARK: Init

    var accountProvider: AccountProvider!
    var biometricsManager: BiometricsManagerType!
    var notificationManager: NotificationManagerType!
    var credentialStore: CredentialsStoreType!
    var repository: LoginRepository!

    init(accountProvider: AccountProvider,
         biometricsManager: BiometricsManagerType,
         notificationManager: NotificationManagerType,
         credentialStore: CredentialsStoreType,
         repository: LoginRepository) {

        self.accountProvider = accountProvider
        self.biometricsManager = biometricsManager
        self.notificationManager = notificationManager
        self.credentialStore = credentialStore
        self.repository = repository

        self.biometrySuject = BehaviorSubject(value: biometricsManager.isBiometryEnabled(for: ""))
        self.biometrySupportedSuject = BehaviorSubject(value: false)
        //
        // FIXME: Enable this after implementing biometrics.
        //      self.biometrySupportedSuject = BehaviorSubject(value: biometricsManager.isBiometrySupported)
        //
        self.biometryTitleSuject = BehaviorSubject(value: biometricsManager.deviceBiometryType.title)

        let logoutRequest = logoutSubject
            .do(onNext: { [unowned self] _ in
                self.biometricsManager.deleteBiometryForUser(phone: credentialStore.getUsername() ?? "")
                YAPProgressHud.showProgressHud()
            })
            .flatMap { _ -> Observable<Event<[String: String]?>> in
                return repository.logout(deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "")
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        logoutRequest.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        logoutRequest.elements()
            .do(onNext: { _ in
                let user = credentialStore.getUsername() ?? ""
                self.biometricsManager.deleteBiometryForUser(phone: user)
                self.notificationManager.deleteNotificationPermission()
                self.credentialStore.setRemembersId(false)
                self.credentialStore.clearUsername()

            })
            .map { _ in () }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)

        accountProvider.currentAccount.unwrap()
            .map{ $0.accountStatus == .addressCaptured && $0.isSecretQuestionVerified == true }
            .bind(to: completeVerificationHiddenSubject)
            .disposed(by: disposeBag)

        completeVerificationSubject.withLatestFrom(accountProvider.currentAccount).unwrap()
            .map({ $0.accountStatus != .addressCaptured })
            .bind(to: completeVerificationResultSubject)
            .disposed(by: disposeBag)

        viewAppearSubject.subscribe(onNext: {
            accountProvider.refreshAccount()
        }).disposed(by: disposeBag)
    }
}
