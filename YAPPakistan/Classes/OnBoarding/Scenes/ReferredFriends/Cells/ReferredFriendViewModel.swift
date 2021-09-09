//
//  ReferredFriendViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 02/09/2021.
//

import Foundation
import RxSwift

protocol ReferredFriendViewModelInput {
}

protocol ReferredFriendViewModelOutput {
    var initialsBackgroundColor: Observable<String?> { get }
    var initialsTextColor: Observable<String?> { get }
    var friendName: Observable<String> { get }
}

protocol ReferredFriendViewModelType {
    var inputs: ReferredFriendViewModelInput { get }
    var outputs: ReferredFriendViewModelOutput { get }
}

class ReferredFriendViewModel: ReferredFriendViewModelInput, ReferredFriendViewModelOutput, ReferredFriendViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let initialsBackgroundColorSubject = BehaviorSubject<String?>(value: nil)
    private let initialsTextColorSubject = BehaviorSubject<String?>(value: nil)
    private let friendNameSubject = BehaviorSubject<String>(value: "")

    var inputs: ReferredFriendViewModelInput { self }
    var outputs: ReferredFriendViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var initialsBackgroundColor: Observable<String?> { initialsBackgroundColorSubject.asObservable() }
    var initialsTextColor: Observable<String?> { initialsTextColorSubject.asObservable() }
    var friendName: Observable<String> { friendNameSubject.asObservable() }

    init(friendName: String, initialsBackgroundColor: String?, initialsTextColor: String?) {
        initialsBackgroundColorSubject.onNext(initialsBackgroundColor)
        initialsTextColorSubject.onNext(initialsTextColor)
        friendNameSubject.onNext(friendName)
    }
}
