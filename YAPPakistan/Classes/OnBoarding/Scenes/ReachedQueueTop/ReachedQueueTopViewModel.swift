//
//  ReachedQueueTopViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 06/09/2021.
//

import Foundation
import RxSwift
import YAPComponents
import RxRelay

protocol ReachedQueueTopViewModelInput {
    var completeVerificationObserver: AnyObserver<Void> { get }
    var createIBAN: AnyObserver<Void> { get }
}

protocol ReachedQueueTopViewModelOutput {
    var heading: Observable<String> { get }
    var subHeading: Observable<String> { get }
    var infoText: Observable<String> { get }
    var verificationButtonTitle: Observable<String> { get }
    var success: Observable<Void> { get }
    var error: Observable<String> { get }
    var ibanCreated: Observable<Void> { get }
    var ibanNumber: Observable<String> { get }
}

protocol ReachedQueueTopViewModelType {
    var inputs: ReachedQueueTopViewModelInput { get }
    var outputs: ReachedQueueTopViewModelOutput { get }
}

class ReachedQueueTopViewModel: ReachedQueueTopViewModelInput, ReachedQueueTopViewModelOutput, ReachedQueueTopViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let headingSubject = BehaviorSubject<String>(value: "")
    private let subHeadingSubject = BehaviorSubject<String>(value: "screen_reached_queue_top_sub_heading_text".localized)
    private let infoTextSubject = BehaviorSubject<String>(value: "screen_reached_queue_top_info_text".localized)
    private let verificationButtonTitleSubject = BehaviorSubject<String>(value: "screen_reached_queue_top_button_complete_verification".localized)
    private let completeVerificationSubject = PublishSubject<Void>()
    private let successSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let createIBANSubject = PublishSubject<Void>()
    private let ibanCreatedSubject = PublishSubject<Void>()
    private let ibanNumberSubject = PublishSubject<String>()

    var inputs: ReachedQueueTopViewModelInput { self }
    var outputs: ReachedQueueTopViewModelOutput { self }

    // MARK: Inputs

    var completeVerificationObserver: AnyObserver<Void> { completeVerificationSubject.asObserver() }
    var createIBAN: AnyObserver<Void> { createIBANSubject.asObserver() }

    // MARK: Outputs

    var heading: Observable<String> { headingSubject.asObservable() }
    var subHeading: Observable<String> { subHeadingSubject.asObservable() }
    var infoText: Observable<String> { infoTextSubject.asObservable() }
    var verificationButtonTitle: Observable<String> { verificationButtonTitleSubject.asObservable() }
    var success: Observable<Void> { successSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var ibanCreated: Observable<Void> { ibanCreatedSubject.asObservable() }
    var ibanNumber: Observable<String> { ibanNumberSubject.asObservable() }

    private var accountRepository: AccountRepositoryType!
    private var accountProvider: AccountProvider!
    
    init(accountProvider: AccountProvider,
         accountRepository: AccountRepositoryType) {
        
        self.accountProvider = accountProvider
        self.accountRepository = accountRepository
        
        accountProvider.currentAccount.subscribe(onNext: { account in
            let name = account?.customer.firstName ?? ""
            self.headingSubject.onNext(String(format: "screen_reached_queue_top_heading_text".localized, name))
        }).disposed(by: disposeBag)

        let completeVerificationRequest = createIBANSubject
            .withLatestFrom(accountProvider.currentAccount).unwrap()
            .do(onNext: {_ in
                YAPProgressHud.showProgressHud()
            })
            .flatMap { [weak self] account -> Observable<Event<String?>> in
                guard let countryCode = account.customer.countryCode else {
                    return .never()
                }
                
                if let iban = account.securedIBANLast7 {
                    self?.ibanNumberSubject.onNext(iban)
                }
                
                return accountRepository.assignIBAN(countryCode: countryCode, mobileNo: account.customer.mobileNo)
            }.share()

        completeVerificationRequest
            .errors()
            .subscribe(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .disposed(by: disposeBag)

        let refreshAccount = completeVerificationRequest.elements()
            .subscribe(onNext: { _ in
                self.localRefreshAccount()
            }).disposed(by: disposeBag)
        
        completeVerificationSubject
                .subscribe(onNext: { [unowned self] _ in
                    print("complete verification button tapped auto")
                    self.successSubject.onNext(())
                    accountProvider.refreshAccount()
                }).disposed(by: disposeBag)
    }
    
    func localRefreshAccount() {
        
        let request = self.accountRepository.fetchAccounts()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
                .share()

        request.elements().subscribe(onNext: { [unowned self] userAccounts in

            if let currentAccount = userAccounts.first {
                // po currentAccount._accountStatus = "ADDRESS_PENDING"
                self.accountProvider.currentAccountValue.accept(currentAccount)
            }
            
            if let iban = accountProvider.currentAccountValue.value?.securedIBANLast7 {
                self.ibanNumberSubject.onNext(iban)
            }
            self.ibanCreatedSubject.onNext(())
            
        }).disposed(by: disposeBag)
        
        request.errors().subscribe(onNext: { error in
            print("refresh account \(error.localizedDescription)")
        }).disposed(by: disposeBag)
        
    }
}
