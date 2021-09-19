//
//  WelcomeViewModel.swift
//  YAP
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol WelcomeViewModelInput {
    var getStartedObserver: AnyObserver<Void> { get }
}

protocol WelcomeViewModelOutput {
    var getStarted: Observable<Void> { get }
    var pageSelected: Observable<Int> { get }
    var welcomePageViewModel: WelcomePageViewModelType { get }
}

protocol WelcomeViewModelType {
    var inputs: WelcomeViewModelInput { get }
    var outputs: WelcomeViewModelOutput { get }
}

class WelcomeViewModel: WelcomeViewModelInput, WelcomeViewModelOutput, WelcomeViewModelType {
    var inputs: WelcomeViewModelInput { return self }
    var outputs: WelcomeViewModelOutput { return self }

    private var getStartedSubject = PublishSubject<Void>()
    private var pageSelectedSubject = PublishSubject<Int>()
    private var pageViewModel: WelcomePageViewModelType!

    // inputs
    var getStartedObserver: AnyObserver<Void> { return getStartedSubject.asObserver() }

    // outputs
    var getStarted: Observable<Void> { return getStartedSubject.asObservable() }
    var pageSelected: Observable<Int> { return pageSelectedSubject.asObservable() }
    var welcomePageViewModel: WelcomePageViewModelType { return pageViewModel }

    private let disposeBag = DisposeBag()

    init() {
        pageViewModel = B2CWelcomPageViewModel()

        pageViewModel.outputs.selectedPage.bind(to: pageSelectedSubject).disposed(by: disposeBag)
    }
}
