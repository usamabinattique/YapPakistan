//
//  SignupFailureViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 03/02/2022.
//

import Foundation
import RxSwift
import UIKit

protocol SignupFailureViewModelInput {
    var backTapObserver: AnyObserver<Void> { get }
    var progressObserver: AnyObserver<Float> { get }
    var startTimeObserver: AnyObserver<Void> { get }
}

protocol SignupFailureViewModelOutput {
    var progress: Observable<Float> { get }
    var progressCompletion: Observable<Bool> { get }
    var backTap: Observable<Void> { get }
    var time: TimeInterval { get }
    var isLogoutHidden: Observable<Bool> { get }
}

protocol SignupFailureViewModelType {
    var inputs: SignupFailureViewModelInput { get }
    var outputs: SignupFailureViewModelOutput { get }
}

class SignupFailureViewModel: SignupFailureViewModelInput, SignupFailureViewModelOutput, SignupFailureViewModelType {
    
    var inputs: SignupFailureViewModelInput { return self }
    var outputs: SignupFailureViewModelOutput { return self }

    private let progressSubject = BehaviorSubject<Float>(value: 0)
    private let progressCompletionSubject = PublishSubject<Bool>()
    private let backTapSubject = PublishSubject<Void>()
    private let startTimeSubject = PublishSubject<Void>()
    private let isLogoutHiddenSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    // inputs
    var backTapObserver: AnyObserver<Void> { return backTapSubject.asObserver() }
    var progressObserver: AnyObserver<Float> { return progressSubject.asObserver() }
    var startTimeObserver: AnyObserver<Void> { return startTimeSubject.asObserver() }

    // outputs
    var progressCompletion: Observable<Bool> { return progressCompletionSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var backTap: Observable<Void> { return backTapSubject.asObservable() }
    var time: TimeInterval { return Date().timeIntervalSince1970 - self.startTime }
    var isLogoutHidden: Observable<Bool> { isLogoutHiddenSubject.asObservable() }

    private let disposeBag = DisposeBag()
    private var timeElappsed: TimeInterval = 0
    private var startTime: TimeInterval = 0
    // private var timeTaken: TimeInterval = 0

    init(isLogutHidden: Bool) {
        isLogoutHiddenSubject.onNext(isLogutHidden)
    }
}
