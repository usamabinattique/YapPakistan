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
    private let animationFileSubject = BehaviorSubject<String>(value: "waitingListStart.mp4")
    private let firstVideoEndedSubject = PublishSubject<Void>()
    private let placeTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_place_text_heading".localized)
    private let rankSubject = BehaviorSubject<String?>(value: "2142")
    private let behindNumberSubject = BehaviorSubject<String?>(value: "4836")
    private let behindYouTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_behind_text".localized)
    private let infoTextSubject = BehaviorSubject<String?>(value: "screen_waiting_list_rank_info_text".localized)
    private let boostUpTextSubject = BehaviorSubject<String>(value: "\("screen_waiting_list_rank_bump_me_up_info_text_top".localized)\n\("screen_waiting_list_rank_bump_me_up_info_text_bottom".localized)")
    private let seeInviteeButtonTitleSubject = BehaviorSubject<String>(value: "screen_waiting_list_rank_invitees_list_button_title_text".localized)
    private let bumpMeUpButtonTitleSubject = BehaviorSubject<String>(value: "screen_waiting_list_rank_bump_me_up_text".localized)

    var inputs: WaitingListRankViewModelInput { self }
    var outputs: WaitingListRankViewModelOutput { self }

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
