//
//  ReferredFriendsViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 02/09/2021.
//

import Foundation
import RxSwift

protocol ReferredFriendsViewModelInput {
}

protocol ReferredFriendsViewModelOutput {
    var titleText: Observable<String> { get }
    var subtitleText: Observable<String> { get }
    var friendList: Observable<[ReferredFriendViewModelType]> { get }
    var hidesSeparator: Observable<Bool> { get }
    var hidesFriends: Observable<Bool> { get }
}

protocol ReferredFriendsViewModelType {
    var inputs: ReferredFriendsViewModelInput { get }
    var outputs: ReferredFriendsViewModelOutput { get }
}

class ReferredFriendsViewModel: ReferredFriendsViewModelInput, ReferredFriendsViewModelOutput, ReferredFriendsViewModelType {

    // MARK: Properties

    private static let colors = [
        (Color(hex: "#f44774"), Color(hex: "#f44774")),
        (Color(hex: "#478df4"), Color(hex: "#478df4")),
        (Color(hex: "#fc6253"), Color(hex: "#f57f17")),
    ]

    private let disposeBag = DisposeBag()

    private let titleSubject = BehaviorSubject<String>(value: "")
    private let subtitleSubject = BehaviorSubject<String>(value: "")
    private let friendListSubject = BehaviorSubject<[ReferredFriendViewModelType]>(value: [])
    private let hidesSeparatorSubject = BehaviorSubject<Bool>(value: true)
    private let hidesFriendsSubject = BehaviorSubject<Bool>(value: true)

    var inputs: ReferredFriendsViewModelInput { self }
    var outputs: ReferredFriendsViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var titleText: Observable<String> { titleSubject.asObservable() }
    var subtitleText: Observable<String> { subtitleSubject.asObservable() }
    var friendList: Observable<[ReferredFriendViewModelType]> { friendListSubject.asObservable() }
    var hidesSeparator: Observable<Bool> { hidesSeparatorSubject.asObservable() }
    var hidesFriends: Observable<Bool> { hidesFriendsSubject.asObservable() }

    init(waitingListRank: WaitingListRank) {
        let invitees = waitingListRank.inviteeDetails ?? []

        friendListSubject
            .filter { $0.isEmpty }
            .map { _ in String(format: "screen_waiting_list_rank_invitees_list_title_text".localized, 0, "😏") }
            .bind(to: titleSubject)
            .disposed(by: disposeBag)

        friendListSubject
            .filter { $0.isEmpty }
            .map { _ in String(format: "screen_waiting_list_rank_invitees_list_subtitle_zero_invitees_text".localized, waitingListRank.jump ?? "0") }
            .bind(to: subtitleSubject)
            .disposed(by: disposeBag)

        friendListSubject
            .filter { !$0.isEmpty }
            .map { _ in String(format: "screen_waiting_list_rank_invitees_list_title_text".localized, invitees.count, "👏") }
            .bind(to: titleSubject)
            .disposed(by: disposeBag)

        friendListSubject
            .filter { !$0.isEmpty }
            .map { _ in String(format: "screen_waiting_list_rank_invitees_list_subtitle_text".localized, waitingListRank.totalGainedPoints ?? 0) }
            .bind(to: subtitleSubject)
            .disposed(by: disposeBag)

        friendListSubject
            .map { $0.isEmpty }
            .bind(to: hidesSeparatorSubject)
            .disposed(by: disposeBag)

        friendListSubject
            .map { $0.isEmpty }
            .bind(to: hidesFriendsSubject)
            .disposed(by: disposeBag)

        let inviteeViewModels = invitees.enumerated().map { (index, invitee) -> ReferredFriendViewModel in
            let colorIndex = index % Self.colors.count

            return ReferredFriendViewModel(friendName: invitee.inviteeCustomerName,
                                           initialsBackgroundColor: Self.colors[colorIndex].0,
                                           initialsTextColor: Self.colors[colorIndex].1,
                                           analyticsTracker: FirebaseAnalyticsTracker(userId: nil, userData: nil))
        }

        friendListSubject.onNext(inviteeViewModels)
    }
}
