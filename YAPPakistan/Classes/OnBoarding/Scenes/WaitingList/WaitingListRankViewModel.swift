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
    private let placeTextSubject = BehaviorSubject<String?>(value: "Your place in the queue")
    private let rankSubject = PublishSubject<String?>()
    private let behindNumberSubject = BehaviorSubject<String?>(value: "")
    private let behindYouTextSubject = BehaviorSubject<String?>(value: "waiting behind you")
    private let infoTextSubject = BehaviorSubject<String?>(value: "We will notify you when you’ve reached the top. Log back in to see your updated place in the queue. ")
    private let boostUpTextSubject = BehaviorSubject<String>(value:
        """
        Want to jump the queue?
        Boost yourself up the queue by 0 for every friend you refer that signs up.🚀
        """)
    private let seeInviteeButtonTitleSubject = BehaviorSubject<String>(value: "Signed up friends: 0")
    private let bumpMeUpButtonTitleSubject = BehaviorSubject<String>(value: "Bump me up the queue")

    var inputs: WaitingListRankViewModelInput { self }
    var outputs: WaitingListRankViewModelOutput { self }

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
                Want to jump the queue?
                Boost yourself up the queue by \(waitingListRank.jump ?? "0") for every friend you refer that signs up.🚀
                """
            )
            self.seeInviteeButtonTitleSubject.onNext("Signed up friends: \(waitingListRank.inviteeDetails?.count ?? 0)")
        }).disposed(by: disposeBag)

        firstVideoEndedSubject
            .map { "waitingListLoop.mp4" }
            .bind(to: animationFileSubject)
            .disposed(by: disposeBag)
    }
}
