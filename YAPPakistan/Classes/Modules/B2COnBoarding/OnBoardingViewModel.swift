//
//  OnBoardingViewModel.swift
//  YAP
//
//  Created by Zain on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OnBoardingViewModelInput {
    var backTapObserver: AnyObserver<Void> { get }
    var progressObserver: AnyObserver<Float> { get }
    var startTimeObserver: AnyObserver<Void> { get }
}

protocol OnBoardingViewModelOutput {
    var progress: Observable<Float> { get }
    var progressCompletion: Observable<Bool> { get }
    var backTap: Observable<Void> { get }
    var time: TimeInterval { get }
}

protocol OnBoardingViewModelType {
    var inputs: OnBoardingViewModelInput { get }
    var outputs: OnBoardingViewModelOutput { get }
}

class OnBoardingViewModel: OnBoardingViewModelInput, OnBoardingViewModelOutput, OnBoardingViewModelType {
    var inputs: OnBoardingViewModelInput { return self }
    var outputs: OnBoardingViewModelOutput { return self }
    
    private let progressSubject = BehaviorSubject<Float>(value: 0)
    private let progressCompletionSubject = PublishSubject<Bool>()
    private let backTapSubject = PublishSubject<Void>()
    private let startTimeSubject = PublishSubject<Void>()
    
    //inputs
    var backTapObserver: AnyObserver<Void> { return backTapSubject.asObserver() }
    var progressObserver: AnyObserver<Float> { return progressSubject.asObserver() }
    var startTimeObserver: AnyObserver<Void> { return startTimeSubject.asObserver() }
    
    //outputs
    var progressCompletion: Observable<Bool> { return progressCompletionSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var backTap: Observable<Void> { return backTapSubject.asObservable() }
    var time: TimeInterval { return timeTaken }
    
    private let disposeBag = DisposeBag()
    private var timeElappsed: TimeInterval = 0
    private var startTime: TimeInterval = 0
    private var timeTaken: TimeInterval = 0
    
    init() {
        startTime = Date().timeIntervalSince1970
        
        progressSubject.subscribe(onNext: { [unowned self] prog in
            if prog == 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    self?.progressCompletionSubject.onNext(true)
                })
            }
            self.timeTaken = Date().timeIntervalSince1970 - self.startTime
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        startTimeSubject.subscribe(onNext: { [unowned self] in self.didEnterForeground() }).disposed(by: disposeBag)
    }
}

private extension OnBoardingViewModel {
    
    @objc func willEnterBackground() {
        guard  startTime != 0 else { return }
        timeElappsed = timeElappsed + (Date().timeIntervalSince1970 - startTime)
    }
    
    @objc func didEnterForeground() {
        startTime = Date().timeIntervalSince1970
    }
}
