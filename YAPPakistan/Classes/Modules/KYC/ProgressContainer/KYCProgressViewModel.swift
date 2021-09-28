//
//  KYCProgressViewModel.swift
//  OnBoarding
//
//  Created by Zain on 06/06/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol KYCProgressViewModelInput {
    var backTapObserver: AnyObserver<Void> { get }
    var progressObserver: AnyObserver<Float> { get }
    var popppedObserver: AnyObserver<Void> { get }
}

protocol KYCProgressViewModelOutput {
    var progress: Observable<Float> { get }
    var progressCompletion: Observable<Bool> { get }
    var backTap: Observable<Void> { get }
}

protocol KYCProgressViewModelType {
    var inputs: KYCProgressViewModelInput { get }
    var outputs: KYCProgressViewModelOutput { get }
}

class KYCProgressViewModel: KYCProgressViewModelInput, KYCProgressViewModelOutput, KYCProgressViewModelType {
    private let progressSubject = BehaviorSubject<Float>(value: 0)
    private let progressCompletionSubject = PublishSubject<Bool>()
    private let backTapSubject = PublishSubject<Void>()
    private let poppedSubject = PublishSubject<Void>()

    var inputs: KYCProgressViewModelInput { self }
    var outputs: KYCProgressViewModelOutput { self }

    // Inputs
    var backTapObserver: AnyObserver<Void> { backTapSubject.asObserver() }
    var progressObserver: AnyObserver<Float> { progressSubject.asObserver() }
    var popppedObserver: AnyObserver<Void> { poppedSubject.asObserver()}

    // Outputs
    var progressCompletion: Observable<Bool> { progressCompletionSubject.asObservable() }
    var progress: Observable<Float> { progressSubject.asObservable() }
    var backTap: Observable<Void> { backTapSubject.asObservable() }

    private let disposeBag = DisposeBag()

    init() {
        poppedSubject.subscribe(onNext: { [weak self] in
            self?.backTapSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
}
