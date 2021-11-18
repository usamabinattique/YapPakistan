//
//  CardStatusViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import RxSwift

protocol CardStatusViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
}

protocol CardStatusViewModelOutputs {
    var back: Observable<Void> { get }
    var next: Observable<Int> { get }
    var isEnabled: Observable<Bool> { get }
    var completedSteps: Observable<Int> { get }
    var localizedStrings: Observable<CardStatusViewModel.LocalizedStrings> { get }
}

protocol CardStatusViewModelType {
    var inputs: CardStatusViewModelInputs { get }
    var outputs: CardStatusViewModelOutputs { get }
}

class CardStatusViewModel: CardStatusViewModelType, CardStatusViewModelInputs, CardStatusViewModelOutputs {

    var inputs: CardStatusViewModelInputs { return self }
    var outputs: CardStatusViewModelOutputs { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var next: Observable<Int> { nextResultSubject.asObservable() }
    var isEnabled: Observable<Bool> { isEnabledSubject.asObservable() }
    var completedSteps: Observable<Int> { completedStepsSubject.asObservable() }
    var localizedStrings: Observable<LocalizedStrings> { localizedStringsSubject.asObservable() }

    // MARK: Subjects
    private var backSubject = PublishSubject<Void>()
    private var nextSubject = PublishSubject<Void>()
    private var nextResultSubject = PublishSubject<Int>()
    private var isEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var completedStepsSubject = BehaviorSubject<Int>(value: 0)
    private var localizedStringsSubject = BehaviorSubject(value: LocalizedStrings())

    // MARK: Properties
    let disposeBag = DisposeBag()

    init(_ strings: LocalizedStrings, completedSteps: Int) {
        localizedStringsSubject.onNext(strings)
        isEnabledSubject.onNext(/* completedSteps == 0 ||*/ completedSteps == 3)
        completedStepsSubject.onNext(completedSteps)
        nextSubject.withLatestFrom(completedStepsSubject).bind(to: nextResultSubject).disposed(by: disposeBag)
    }

    struct LocalizedStrings {
        let title: String
        let subTitle: String
        let message: String
        let status: (order: String, build: String, ship: String)
        let action: String

        init() {
            self.init(title: "",
                      subTitle: "",
                      message: "",
                      status: ("", "", ""),
                      action: "")
        }

        init(title: String,
             subTitle: String,
             message: String,
             status: (order: String, build: String, ship: String),
             action: String) {
            self.title = title
            self.subTitle = subTitle
            self.message = message
            self.status = status
            self.action = action
        }
    }
}
