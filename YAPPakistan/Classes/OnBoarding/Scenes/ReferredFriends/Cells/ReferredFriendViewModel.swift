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
    var initialsBackgroundColor: Observable<UIColor?> { get }
    var initialsTextColor: Observable<UIColor?> { get }
    var friendName: Observable<String> { get }
}

protocol ReferredFriendViewModelType {
    var inputs: ReferredFriendViewModelInput { get }
    var outputs: ReferredFriendViewModelOutput { get }
}

class ReferredFriendViewModel: ReferredFriendViewModelInput, ReferredFriendViewModelOutput, ReferredFriendViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private let initialsBackgroundColorSubject = BehaviorSubject<UIColor?>(value: nil)
    private let initialsTextColorSubject = BehaviorSubject<UIColor?>(value: nil)
    private let friendNameSubject = BehaviorSubject<String>(value: "")

    var inputs: ReferredFriendViewModelInput { self }
    var outputs: ReferredFriendViewModelOutput { self }

    // MARK: Inputs

    // MARK: Outputs

    var initialsBackgroundColor: Observable<UIColor?> { initialsBackgroundColorSubject.asObservable() }
    var initialsTextColor: Observable<UIColor?> { initialsTextColorSubject.asObservable() }
    var friendName: Observable<String> { friendNameSubject.asObservable() }

    init(friendName: String, initialsBackgroundColor: UIColor?, initialsTextColor: UIColor?) {
        initialsBackgroundColorSubject.onNext(initialsBackgroundColor)
        initialsTextColorSubject.onNext(initialsTextColor)
        friendNameSubject.onNext(friendName)
    }
}
