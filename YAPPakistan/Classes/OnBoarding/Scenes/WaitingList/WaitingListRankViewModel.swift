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

protocol WaitingListRankViewModelInput {
    var getRanking: AnyObserver<Bool> { get }
    var firstVideoEnded: AnyObserver<Void> { get }
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
}

protocol WaitingListRankViewModelType {
    var inputs: WaitingListRankViewModelInput { get }
    var outputs: WaitingListRankViewModelOutput { get }
}

class WaitingListRankViewModel: WaitingListRankViewModelInput, WaitingListRankViewModelOutput, WaitingListRankViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let getRankingSubject = PublishSubject<Bool>()
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
    private let boostUpTextSubject = BehaviorSubject<String>(value: "\(bumpUpMessageTop)\n\(bumpUpMessageBottom)")
    private let seeInviteeButtonTitleSubject = BehaviorSubject<String>(value: String(format: "screen_waiting_list_rank_invitees_list_button_title_text".localized, 0))
    private let bumpMeUpButtonTitleSubject = BehaviorSubject<String>(value: "screen_waiting_list_rank_bump_me_up_text".localized)

    var inputs: WaitingListRankViewModelInput { self }
    var outputs: WaitingListRankViewModelOutput { self }

    private static let bumpUpMessageTop = "screen_waiting_list_rank_bump_me_up_info_text_top".localized
    private static let bumpUpMessageBottom = "screen_waiting_list_rank_bump_me_up_info_text_bottom".localized

    // MARK: Inputs

    var getRanking: AnyObserver<Bool> { getRankingSubject.asObserver() }
    var firstVideoEnded: AnyObserver<Void> { firstVideoEndedSubject.asObserver() }

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

    init(onBoardingRepository: OnBoardingRepository) {
        let getRankingRequest = getRankingSubject.share()
        getRankingRequest.map { $0 }
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)

        let result = getRankingRequest.flatMap { _ in
            onBoardingRepository.getWaitingListRanking()
        }.share(replay: 1, scope: .whileConnected)

        result
            .map { _ in false }
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)

        result.elements().unwrap().subscribe(onNext: { [weak self] waitingListRank in
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

        firstVideoEndedSubject
            .map { "waitingListLoop.mp4" }
            .bind(to: animationFileSubject)
            .disposed(by: disposeBag)
    }
}
