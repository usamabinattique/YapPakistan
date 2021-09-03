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
}

protocol ReferredFriendsViewModelType {
    var inputs: ReferredFriendsViewModelInput { get }
    var outputs: ReferredFriendsViewModelOutput { get }
}

class ReferredFriendsViewModel: ReferredFriendsViewModelInput, ReferredFriendsViewModelOutput, ReferredFriendsViewModelType {

    // MARK: Properties

    private static let colors = [
        (UIColor(hex: 0xf44774, transparency: 0.16), UIColor(hex: 0xf44774)),
        (UIColor(hex: 0x478df4, transparency: 0.16), UIColor(hex: 0x478df4)),
        (UIColor(hex: 0xfc6253, transparency: 0.16), UIColor(hex: 0xf57f17)),
    ]

    private let disposeBag = DisposeBag()

    private let getRankingSubject = PublishSubject<Bool>()
    private let titleSubject = BehaviorSubject<String>(value: "You referred 0 friends! 😏")
    private let subtitleSubject = BehaviorSubject<String>(value: "Once your referred friends sign up, you will see their names listed below and your place in the queue bumped up by 100 spots for each friend!")
    private let friendListSubject = BehaviorSubject<[ReferredFriendViewModelType]>(value:
        [
            ReferredFriendViewModel(friendName: "Logan Pearson",
                                    initialsBackgroundColor: colors[0].0,
                                    initialsTextColor: colors[0].1),
            ReferredFriendViewModel(friendName: "Virginia Alvarado",
                                    initialsBackgroundColor: colors[1].0,
                                    initialsTextColor: colors[1].1),
            ReferredFriendViewModel(friendName: "Bruce Guerrero",
                                    initialsBackgroundColor: colors[2].0,
                                    initialsTextColor: colors[2].1),
            ReferredFriendViewModel(friendName: "Emma Weber",
                                    initialsBackgroundColor: colors[0].0,
                                    initialsTextColor: colors[0].1),
            ReferredFriendViewModel(friendName: "Nada Hassan",
                                    initialsBackgroundColor: colors[1].0,
                                    initialsTextColor: colors[1].1)
        ])

    var inputs: ReferredFriendsViewModelInput { self }
    var outputs: ReferredFriendsViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var titleText: Observable<String> { titleSubject.asObservable() }
    var subtitleText: Observable<String> { subtitleSubject.asObservable() }
    var friendList: Observable<[ReferredFriendViewModelType]> { friendListSubject.asObservable() }
}
