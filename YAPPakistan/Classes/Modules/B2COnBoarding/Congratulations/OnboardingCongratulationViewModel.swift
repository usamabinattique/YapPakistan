//
//  OnboardingCongratulationViewModel.swift
//  YAP
//
//  Created by Muhammad Hassan on 05/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

protocol OnboardingCongratulationViewModelInputs {
    var completeVerificationObserver: AnyObserver<Void> { get }
    var stageObserver: AnyObserver<OnboardingStage> { get }
    var progressObserver: AnyObserver<Float> { get }
}

protocol OnboardingCongratulationViewModelOutputs {
    var name: Observable<String> { get }
    var onboardingInterval: Observable<TimeInterval> { get }
    var iban: Observable<String> { get }
    var stage: Observable<OnboardingStage> { get }
    var completeVerification: Observable<Void> { get }
    var progress: Observable<Float> { get }
    var onBoardingUserObj: OnBoardingUser { get }
}

protocol OnboardingCongratulationViewModelType {
    var inputs: OnboardingCongratulationViewModelInputs { get }
    var outputs: OnboardingCongratulationViewModelOutputs { get }
}

class OnboardingCongratulationViewModel: OnboardingCongratulationViewModelType, OnboardingCongratulationViewModelInputs, OnboardingCongratulationViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()

    let nameSubject: BehaviorSubject<String?>!
    let onboardingIntervalSubject: BehaviorSubject<TimeInterval?>!
    let ibanSubject: BehaviorSubject<String?>!
    private let stageSubject = PublishSubject<OnboardingStage>()
    let completeVerificationSubject = PublishSubject<Void>()
    private let progressSubject = PublishSubject<Float>()

    public var inputs: OnboardingCongratulationViewModelInputs { return self }
    public var outputs: OnboardingCongratulationViewModelOutputs { return self }

    // MARK: - Inputs
    public var completeVerificationObserver: AnyObserver<Void> { return completeVerificationSubject.asObserver() }
    var stageObserver: AnyObserver<OnboardingStage> { return stageSubject.asObserver() }
    public var progressObserver: AnyObserver<Float> { return progressSubject.asObserver() }

    // MARK: - Outputs
    public var name: Observable<String> { return nameSubject.unwrap().asObservable() }
    public var onboardingInterval: Observable<TimeInterval> { return onboardingIntervalSubject.unwrap().asObservable() }
    public var iban: Observable<String> { return ibanSubject.unwrap().map { format(iban: mask(iban: $0)) }.asObservable() }
    var stage: Observable<OnboardingStage> { return stageSubject.asObservable() }
    public var completeVerification: Observable<Void> { return completeVerificationSubject.asObservable() }
    public var  progress:  Observable<Float> { return progressSubject.asObservable() }
    public var onBoardingUserObj: OnBoardingUser

    // MARK: - Init
    init(user: OnBoardingUser, analyticsTracker: AnalyticsTracker) {
        
        onBoardingUserObj = user
        
        self.nameSubject = BehaviorSubject(value: user.firstName)
        self.onboardingIntervalSubject = BehaviorSubject(value: user.timeTaken)
        self.ibanSubject = BehaviorSubject(value: user.iban)

        let seconds = Int(user.timeTaken.truncatingRemainder(dividingBy: 60.0))
        let minutes = Int(user.timeTaken / 60)
        
        analyticsTracker.trackAdjustEventWithToken("92ou1s", customerId: nil, andParameters: nil)
        analyticsTracker.trackFirebaseEvent("pk_signup_end", withParameters: [:])
        analyticsTracker.trackLeanplumEvent("pk_signup_end", withParameters: [:])
        
        UserDefaults.standard.set(true, forKey: "SHOWS_APPLICATION_STATUS_ON_DASHBOARD")
    }
}
