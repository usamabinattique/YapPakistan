//
//  ReachedQueueTopViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 06/09/2021.
//

import Foundation
import RxSwift

protocol ReachedQueueTopViewModelInput {
    var completeVerification: AnyObserver<Void> { get }
}

protocol ReachedQueueTopViewModelOutput {
    var heading: Observable<String> { get }
    var subHeading: Observable<String> { get }
    var infoText: Observable<String> { get }
    var verificationButtonTitle: Observable<String> { get }
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

    var inputs: ReachedQueueTopViewModelInput { self }
    var outputs: ReachedQueueTopViewModelOutput { self }

    // MARK: Inputs

    var completeVerification: AnyObserver<Void> { completeVerificationSubject.asObserver() }

    // MARK: Outputs

    var heading: Observable<String> { headingSubject.asObservable() }
    var subHeading: Observable<String> { subHeadingSubject.asObservable() }
    var infoText: Observable<String> { infoTextSubject.asObservable() }
    var verificationButtonTitle: Observable<String> { verificationButtonTitleSubject.asObservable() }

    init(accountProvider: AccountProvider) {
        accountProvider.currentAccount.subscribe(onNext: { account in
            let name = account?.customer.firstName ?? ""
            self.headingSubject.onNext(String(format: "screen_reached_queue_top_heading_text".localized, name))
        }).disposed(by: disposeBag)
    }
}
