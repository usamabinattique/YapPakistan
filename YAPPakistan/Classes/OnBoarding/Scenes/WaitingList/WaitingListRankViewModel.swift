//
//  OnboardingWaitingListRankViewModel.swift
//  OnBoarding
//
//  Created by Muhammad Awais on 25/02/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore

protocol WaitingListRankViewModelInput {
    var firstVideoEnded: AnyObserver<Void> { get }
    var getRanking: AnyObserver<Bool> { get }
    var bumpMeUp: AnyObserver<Void> { get }
}

protocol WaitingListRankViewModelOutput {
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var waitingListRank: Observable<WaitingListRank> { get }
    var animationFile: Observable<String> { get }
    var placeText: Observable<String?> { get }
    var rank: Observable<String?> { get }
    var behindNumber: Observable<String?> { get }
    var behindYouText: Observable<String?> { get }
    var infoText: Observable<String?> { get }
    var boostUpText: Observable<String> { get }
    var seeInviteeButtonTitle: Observable<String> { get }
    var bumpMeUpButtonTitle: Observable<String> { get }
    var shareInfo: Observable<String> { get }
}

protocol WaitingListRankViewModelType {
    var inputs: WaitingListRankViewModelInput { get }
    var outputs: WaitingListRankViewModelOutput { get }
}

class WaitingListRankViewModel: WaitingListRankViewModelInput, WaitingListRankViewModelOutput, WaitingListRankViewModelType {

    // MARK: Properties

    private let accountProvider: AccountProvider
    private let referralManager: AppReferralManager

    private let disposeBag = DisposeBag()

    private let getRankingSubject = PublishSubject<Bool>()
    private let bumpMeUpSubject = PublishSubject<Void>()
    private let loadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<String>()
    private let waitingListRankSubject = PublishSubject<WaitingListRank>()
    private let animationFileSubject = BehaviorSubject<String>(value: "waitingListStart.mp4")
    private let firstVideoEndedSubject = PublishSubject<Void>()
    private let placeTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_place_text_heading".localized)
    private let rankSubject = PublishSubject<String?>()
    private let behindNumberSubject = BehaviorSubject<String?>(value: "")
    private let behindYouTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_behind_text".localized)
    private let infoTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_info_text".localized)
    private let boostUpTextSubject = BehaviorSubject<String>(value: "\("screen_waiting_list_rank_bump_me_up_info_text_top".localized)\n\("screen_waiting_list_rank_bump_me_up_info_text_bottom".localized)")
    private let seeInviteeButtonTitleSubject = BehaviorSubject<String>(value: String(format: "screen_waiting_list_rank_invitees_list_button_title_text".localized, 0))
    private let bumpMeUpButtonTitleSubject = BehaviorSubject<String>(value: "screen_waiting_list_rank_bump_me_up_text".localized)
    private let shareInfoSubject = PublishSubject<String>()

    var inputs: WaitingListRankViewModelInput { self }
    var outputs: WaitingListRankViewModelOutput { self }

    // MARK: Inputs

    var firstVideoEnded: AnyObserver<Void> { firstVideoEndedSubject.asObserver() }
    var getRanking: AnyObserver<Bool> { getRankingSubject.asObserver() }
    var bumpMeUp: AnyObserver<Void> { bumpMeUpSubject.asObserver() }

    // MARK: Outputs

    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var waitingListRank: Observable<WaitingListRank> { waitingListRankSubject.asObservable() }
    var animationFile: Observable<String> { animationFileSubject.asObservable() }
    var placeText: Observable<String?> { placeTextSubject.asObservable() }
    var rank: Observable<String?> { rankSubject.asObservable() }
    var behindNumber: Observable<String?> { behindNumberSubject.asObservable() }
    var behindYouText: Observable<String?> { behindYouTextSubject.asObservable() }
    var boostUpText: Observable<String> { boostUpTextSubject.asObservable() }
    var infoText: Observable<String?> { infoTextSubject.asObservable() }
    var seeInviteeButtonTitle: Observable<String> { seeInviteeButtonTitleSubject.asObservable() }
    var bumpMeUpButtonTitle: Observable<String> { bumpMeUpButtonTitleSubject.asObservable() }
    var shareInfo: Observable<String> { shareInfoSubject.asObservable() }

    init(accountProvider: AccountProvider,
         referralManager: AppReferralManager,
         onBoardingRepository: OnBoardingRepository) {
        self.accountProvider = accountProvider
        self.referralManager = referralManager

        accountProvider.refreshAccount()

        let getRankingRequest = getRankingSubject.share()
        getRankingRequest.map { $0 }
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)

        let rankResult = getRankingRequest.flatMap { _ in
            onBoardingRepository.getWaitingListRanking()
        }.share(replay: 1, scope: .whileConnected)

        rankResult
            .map { _ in false }
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)

        rankResult.elements().unwrap().subscribe(onNext: { [weak self] waitingListRank in
            guard let self = self else { return }

            self.waitingListRankSubject.onNext(waitingListRank)
            self.rankSubject.onNext(String(waitingListRank.waitingNewRank))
            self.behindNumberSubject.onNext(String(waitingListRank.waitingBehind))
            self.boostUpTextSubject.onNext(
                """
                \("screen_waiting_list_rank_bump_me_up_info_text_top".localized)
                \(String(format: "screen_waiting_list_rank_bump_me_up_info_text_bottom".localized, waitingListRank.jump ?? "0"))
                """
            )
            self.seeInviteeButtonTitleSubject.onNext(String(format: "screen_waiting_list_rank_invitees_list_button_title_text".localized, waitingListRank.inviteeDetails?.count ?? 0))
        }).disposed(by: disposeBag)

        let customerId = accountProvider.currentAccount
            .map { $0?.customer.customerId }.unwrap()

        let sendInviteRequest = bumpMeUpSubject.withLatestFrom(customerId)

        let sendInviteResult = sendInviteRequest
            .flatMap { customerId -> Observable<Event<String?>> in
                self.loadingSubject.onNext(true)

                let formatter = DateFormatter()
                formatter.dateFormat = DateFormatter.serverReadableDateTimeFormat

                let date = formatter.string(from: Date())

                return onBoardingRepository.saveInvite(inviterCustomerId: customerId, referralDate: date)
            }
            .do(onNext: { _ in
                self.loadingSubject.onNext(false)
            })

        sendInviteResult.withLatestFrom(customerId)
            .map { appInviteWaitingList(referralManager.pkReferralURL(forInviter: $0)) }
            .bind(to: shareInfoSubject)
            .disposed(by: disposeBag)

        firstVideoEndedSubject
            .map { "waitingListLoop.mp4" }
            .bind(to: animationFileSubject)
            .disposed(by: disposeBag)
    }
}
