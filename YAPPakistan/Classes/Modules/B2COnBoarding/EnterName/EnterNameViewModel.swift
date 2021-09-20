//
//  EnterNameViewModel.swift
//  YAP
//
//  Created by Zain on 27/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol EnterNameViewModelInput {
    var firstNameObserver: AnyObserver<String?> { get }
    var lastNameObserver: AnyObserver<String?> { get }
    var viewAppearedObserver: AnyObserver<Bool> { get }
    var sendObserver: AnyObserver<OnboardingStage> { get }
    var keyboardNextObserver: AnyObserver<Void> { get }
    var firstNameInputObserver: AnyObserver<String> { get }
    var lastNameInputObserver: AnyObserver<String> { get }
    var stageObserver: AnyObserver<OnboardingStage> { get }
    var poppedObserver: AnyObserver<Void> { get }
}

protocol EnterNameViewModelOutput {
    var result: Observable<OnBoardingUser> { get }
    var valid: Observable<Bool> { get }
    var firstNameValidation: Observable<AppRoundedTextFieldValidation> { get }
    var lastNameValidation: Observable<AppRoundedTextFieldValidation> { get }
    var firstNameError: Observable<String?> { get }
    var lastNameError: Observable<String?> { get }
    var allowedFirstNameInput: Observable<Bool> { get }
    var allowedLasttNameInput: Observable<Bool> { get }
    var progress: Observable<Float> { get }
    var stage: Observable<OnboardingStage> { get }
}

protocol EnterNameViewModelType {
    var inputs: EnterNameViewModelInput { get }
    var outputs: EnterNameViewModelOutput { get }
}

class EnterNameViewModel: EnterNameViewModelInput, EnterNameViewModelOutput, EnterNameViewModelType {

    var inputs: EnterNameViewModelInput { return self }
    var outputs: EnterNameViewModelOutput { return self }

    private let firstNameSubject = BehaviorSubject<String?>(value: nil)
    private let lastNameSubject = BehaviorSubject<String?>(value: nil)
    private let viewAppearedSubject = PublishSubject<Bool>()
    private let sendSubject = PublishSubject<OnboardingStage>()
    private let resultSubject = PublishSubject<OnBoardingUser>()
    private let validSubject = BehaviorSubject<Bool>(value: false)
    private let firstNameValidationSubject = PublishSubject<AppRoundedTextFieldValidation>()
    private let lastNameValidationSubject = PublishSubject<AppRoundedTextFieldValidation>()
    private let firstNameErrorSubject = BehaviorSubject<String?>(value: nil)
    private let lastNameErrorSubject = BehaviorSubject<String?>(value: nil)
    private let firstNameInputSubject = PublishSubject<String>()
    private let lastNameInputSubject = PublishSubject<String>()
    private let allowedFirstNameInputSubject = BehaviorSubject<Bool>(value: true)
    private let allowedLastNameInputSubject = BehaviorSubject<Bool>(value: true)
    private let keyboardNextSubject = PublishSubject<Void>()
    private let progressSubject = PublishSubject<Float>()
    private let stageSubject = PublishSubject<OnboardingStage>()
    private let poppedSubject = PublishSubject<Void>()

    // inputs
    var firstNameObserver: AnyObserver<String?> { return firstNameSubject.asObserver() }
    var lastNameObserver: AnyObserver<String?> { return lastNameSubject.asObserver() }
    var viewAppearedObserver: AnyObserver<Bool> { return viewAppearedSubject.asObserver() }
    var sendObserver: AnyObserver<OnboardingStage> { return sendSubject.asObserver() }
    var firstNameInputObserver: AnyObserver<String> { return firstNameInputSubject.asObserver() }
    var lastNameInputObserver: AnyObserver<String> { return lastNameInputSubject.asObserver() }
    var keyboardNextObserver: AnyObserver<Void> { return keyboardNextSubject.asObserver() }
    var stageObserver: AnyObserver<OnboardingStage> { return stageSubject.asObserver() }
    var poppedObserver: AnyObserver<Void> { return poppedSubject.asObserver() }

    // outputs
    var result: Observable<OnBoardingUser> { return resultSubject.asObservable() }
    var valid: Observable<Bool> { return validSubject.asObservable() }
    var firstNameValidation: Observable<AppRoundedTextFieldValidation> { return firstNameValidationSubject.asObservable() }
    var lastNameValidation: Observable<AppRoundedTextFieldValidation> { return lastNameValidationSubject.asObservable() }
    var firstNameError: Observable<String?> { return firstNameErrorSubject.asObservable() }
    var lastNameError: Observable<String?> { return lastNameErrorSubject.asObservable() }
    var allowedFirstNameInput: Observable<Bool> { return allowedFirstNameInputSubject.asObservable() }
    var allowedLasttNameInput: Observable<Bool> { return allowedLastNameInputSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var stage: Observable<OnboardingStage> { return stageSubject.asObservable() }

    private var user: OnBoardingUser!
    private let disposeBag = DisposeBag()
    private var isValidInput = false
    private let whiteListCharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ")

    init(user: OnBoardingUser) {
        self.user = user
        let isFirstNameValid = firstNameSubject.map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .do(onNext: { [unowned self] in
                self.user.firstName = $0 })
            .map { ValidationService.shared.validateName($0) }
        let isLastNameValid = lastNameSubject.map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .do(onNext: { [unowned self] in
                self.user.lastName = $0 })
            .map { ValidationService.shared.validateLastName($0) }

        Observable.combineLatest(isFirstNameValid, isLastNameValid).do(onNext: { [unowned self] in
            self.isValidInput = $0 && $1
        }).map { [unowned self] _ in self.isValidInput }.bind(to: validSubject).disposed(by: disposeBag)

        let viewAppeared = viewAppearedSubject.filter { $0 }
        viewAppeared.map { [unowned self] _ in self.isValidInput }.bind(to: validSubject).disposed(by: disposeBag)
        viewAppeared.map { [unowned self] _ in self.user.accountType == .b2cAccount ? 0.6 : 0.714 }.bind(to: progressSubject).disposed(by: disposeBag)

        firstNameInputSubject.map { [unowned self] in self.whiteListCharacterSet.isSuperset(of: CharacterSet(charactersIn: $0)) }.bind(to: allowedFirstNameInputSubject).disposed(by: disposeBag)
        lastNameInputSubject.map { [unowned self] in self.whiteListCharacterSet.isSuperset(of: CharacterSet(charactersIn: $0)) }.bind(to: allowedLastNameInputSubject).disposed(by: disposeBag)

        allowedFirstNameInputSubject.map { $0 ? nil :  "screen_name_special_character_error".localized }.bind(to: firstNameErrorSubject).disposed(by: disposeBag)
        allowedLastNameInputSubject.map { $0 ? nil :  "screen_name_special_character_error".localized }.bind(to: lastNameErrorSubject).disposed(by: disposeBag)

        Observable.merge(isFirstNameValid.map { $0 ? .valid : .neutral },
                         allowedFirstNameInputSubject.filter { !$0 }
                            .map { _ in .invalid(nil) })
            .bind(to: firstNameValidationSubject).disposed(by: disposeBag)

        Observable.merge(isLastNameValid.map { $0 ? .valid : .neutral },
                         allowedLastNameInputSubject.filter { !$0 }
                            .map { _ in .invalid(nil) })
            .bind(to: lastNameValidationSubject).disposed(by: disposeBag)

        keyboardNextSubject
            .withLatestFrom(validSubject)
            .filter { $0 }
            .map { _ in .name }
            .bind(to: sendSubject)
            .disposed(by: disposeBag)

        sendSubject.filter { $0 == .name }.map { [unowned self] _ in self.user }.bind(to: resultSubject).disposed(by: disposeBag)

        poppedSubject.subscribe(onNext: { [unowned self] in
            self.resultSubject.onCompleted()
            self.validSubject.onCompleted()
            self.stageSubject.onCompleted()
            self.progressSubject.onCompleted()
            self.sendSubject.dispose()
        }).disposed(by: disposeBag)

        // resultSubject.withLatestFrom(Observable.combineLatest(firstNameSubject, lastNameSubject))
            // .map{ [$0.0, $0.1].compactMap{ $0 }.joined(separator: " ")}
            // .map { OnBoardingEvent.nameEntered(["name" : $0]) }
            // .bind(to: AppAnalytics.shared.rx.logEvent)
            // .disposed(by: disposeBag)
    }
}
