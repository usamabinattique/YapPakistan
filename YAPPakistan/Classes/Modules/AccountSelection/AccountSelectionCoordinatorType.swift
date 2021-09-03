//
//  AccountSelectionCoordinatorType.swift
//  App
//
//  Created by Hussaan S on 25/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
/*
import Foundation
import UIKit
import RxSwift
import YAPKit
import YAP
import OnBoarding

protocol AccountSelectionCoordinatorType: Coordinator<ResultType<Void>> {
    
    var root: UINavigationController! { get }
    var result: PublishSubject<ResultType<Void>> { get }
    var loginResult: PublishSubject<ResultType<Void>> { get }
    var welcomeResult: PublishSubject<ResultType<Void>> { get }
    var b2cOnboardingResult: PublishSubject<ResultType<Void>> { get }
    
    func login()
    func welcome()
    func b2cOnboarding()
}

extension AccountSelectionCoordinatorType {
    
    func welcome() {
//        coordinate(to: B2CKYCCoordinator(root: root)).subscribe().disposed(by: disposeBag)
        
        coordinate(to: WelcomeCoordinator(navigationController: self.root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.welcomeResult.onNext(result)
            })
            .disposed(by: disposeBag)
    }
    
    func b2cOnboarding() {
//        coordinate(to: HouseholdOnBoardingCoordinator(navigationController: self.root))
        coordinate(to: B2COnBoardingCoordinator(navigationController: self.root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.b2cOnboardingResult.onNext(result)
            })
            .disposed(by: disposeBag)
    }
    
    func login() {
        coordinate(to: LoginCoordinatorPushable(root: root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.loginResult.onNext(result)
            })
            .disposed(by: disposeBag)
    }
}
*/
