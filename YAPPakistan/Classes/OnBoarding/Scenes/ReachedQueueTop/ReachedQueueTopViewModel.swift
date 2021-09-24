//
//  ReachedQueueTopViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 06/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

protocol ReachedQueueTopViewModelInput {
    var completeVerificationObserver: AnyObserver<Void> { get }
}

protocol ReachedQueueTopViewModelOutput {
    var heading: Observable<String> { get }
    var subHeading: Observable<String> { get }
    var infoText: Observable<String> { get }
    var verificationButtonTitle: Observable<String> { get }
    var success: Observable<Void> { get }
    var error: Observable<String> { get }
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

    var inputs: ReachedQueueTopViewModelInput { self }
    var outputs: ReachedQueueTopViewModelOutput { self }

    // MARK: Inputs

    var completeVerificationObserver: AnyObserver<Void> { completeVerificationSubject.asObserver() }

    // MARK: Outputs

    var heading: Observable<String> { headingSubject.asObservable() }
    var subHeading: Observable<String> { subHeadingSubject.asObservable() }
    var infoText: Observable<String> { infoTextSubject.asObservable() }
    var verificationButtonTitle: Observable<String> { verificationButtonTitleSubject.asObservable() }
    var success: Observable<Void> { successSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }

    init(accountProvider: AccountProvider,
         accountRepository: AccountRepositoryType) {
        accountProvider.currentAccount.subscribe(onNext: { account in
            let name = account?.customer.firstName ?? ""
            self.headingSubject.onNext(String(format: "screen_reached_queue_top_heading_text".localized, name))
        }).disposed(by: disposeBag)

        let completeVerificationRequest = completeVerificationSubject
            .withLatestFrom(accountProvider.currentAccount).unwrap()
            .do(onNext: {_ in
                YAPProgressHud.showProgressHud()
            })
            .flatMap { account -> Observable<Event<String?>> in
                guard let countryCode = account.customer.countryCode else {
                    return .never()
                }

                return accountRepository.assignIBAN(countryCode: countryCode, mobileNo: account.customer.mobileNo)
            }.share()

        completeVerificationRequest
            .errors()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .map{ $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

        let refreshAccount = completeVerificationRequest.elements()
            .flatMap { _ in
                accountProvider.refreshAccount()
            }
            .share()

        refreshAccount
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            }).subscribe(onNext: { [unowned self] _ in
                self.successSubject.onNext(())
            }).disposed(by: disposeBag)
    }
}
