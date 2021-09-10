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
    var initialsBackgroundColor: Observable<Color?> { get }
    var initialsTextColor: Observable<Color?> { get }
    var friendName: Observable<String> { get }
}

protocol ReferredFriendViewModelType {
    var inputs: ReferredFriendViewModelInput { get }
    var outputs: ReferredFriendViewModelOutput { get }
}

class ReferredFriendViewModel: ReferredFriendViewModelInput, ReferredFriendViewModelOutput, ReferredFriendViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let initialsBackgroundColorSubject = BehaviorSubject<Color?>(value: nil)
    private let initialsTextColorSubject = BehaviorSubject<Color?>(value: nil)
    private let friendNameSubject = BehaviorSubject<String>(value: "")

    var inputs: ReferredFriendViewModelInput { self }
    var outputs: ReferredFriendViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var initialsBackgroundColor: Observable<Color?> { initialsBackgroundColorSubject.asObservable() }
    var initialsTextColor: Observable<Color?> { initialsTextColorSubject.asObservable() }
    var friendName: Observable<String> { friendNameSubject.asObservable() }

    init(friendName: String, initialsBackgroundColor: Color?, initialsTextColor: Color?) {
        initialsBackgroundColorSubject.onNext(initialsBackgroundColor)
        initialsTextColorSubject.onNext(initialsTextColor)
        friendNameSubject.onNext(friendName)
    }
}
