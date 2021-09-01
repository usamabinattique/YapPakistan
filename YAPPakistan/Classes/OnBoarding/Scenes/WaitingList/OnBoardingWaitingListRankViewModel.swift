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

protocol OnBoardingWaitingListRankViewModelInput {
    var getRanking: AnyObserver<Bool> { get }
    var firstVideoEnded: AnyObserver<Void> { get }
}

protocol OnBoardingWaitingListRankViewModelOutput {
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
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

protocol OnBoardingWaitingListRankViewModelType {
    var inputs: OnBoardingWaitingListRankViewModelInput { get }
    var outputs: OnBoardingWaitingListRankViewModelOutput { get }
}

class OnBoardingWaitingListRankViewModel: OnBoardingWaitingListRankViewModelInput, OnBoardingWaitingListRankViewModelOutput, OnBoardingWaitingListRankViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let getRankingSubject = PublishSubject<Bool>()
    private let loadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<String>()
    private let animationFileSubject = BehaviorSubject<String>(value: "waitingListStart.mp4")
    private let firstVideoEndedSubject = PublishSubject<Void>()
    private let placeTextSubject = BehaviorSubject<String?>(value: "Your place in the queue")
    private let rankSubject = BehaviorSubject<String?>(value: "2142")
    private let behindNumberSubject = BehaviorSubject<String?>(value: "4836")
    private let behindYouTextSubject = BehaviorSubject<String?>(value: "waiting behind you")
    private let infoTextSubject = BehaviorSubject<String?>(value: "We will notify you when you’ve reached the top. Log back in to see your updated place in the queue. ")
    private let boostUpTextSubject = BehaviorSubject<String>(value:
        """
        Want to jump the queue?
        Boost yourself up the queue by 100 for every friend you refer that signs up.🚀
        """)
    private let seeInviteeButtonTitleSubject = BehaviorSubject<String>(value: "Signed up friends: 0")
    private let bumpMeUpButtonTitleSubject = BehaviorSubject<String>(value: "Bump me up the queue")

    var inputs: OnBoardingWaitingListRankViewModelInput { self }
    var outputs: OnBoardingWaitingListRankViewModelOutput { self }

    // MARK: Inputs

    var getRanking: AnyObserver<Bool> { getRankingSubject.asObserver() }
    var firstVideoEnded: AnyObserver<Void> { firstVideoEndedSubject.asObserver() }
    
    // MARK: Outputs

    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var animationFile: Observable<String> { animationFileSubject.asObservable() }
    var placeText: Observable<String?> { placeTextSubject.asObservable() }
    var rank: Observable<String?> { rankSubject.asObservable() }
    var behindNumber: Observable<String?> { behindNumberSubject.asObservable() }
    var behindYouText: Observable<String?> { behindYouTextSubject.asObservable() }
    var boostUpText: Observable<String> { boostUpTextSubject.asObservable() }
    var infoText: Observable<String?> { infoTextSubject.asObservable() }
    var seeInviteeButtonTitle: Observable<String> { seeInviteeButtonTitleSubject.asObservable() }
    var bumpMeUpButtonTitle: Observable<String> { bumpMeUpButtonTitleSubject.asObservable() }
    
    init() {
        firstVideoEndedSubject
            .map { "waitingListLoop.mp4" }
            .bind(to: animationFileSubject)
            .disposed(by: disposeBag)
    }
}
