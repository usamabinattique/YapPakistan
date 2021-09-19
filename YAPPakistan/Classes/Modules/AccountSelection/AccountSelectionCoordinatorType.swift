//
//  AccountSelectionCoordinatorType.swift
//  App
//
//  Created by Hussaan S on 25/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import YAPCore

public protocol AccountSelectionCoordinatorType: Coordinator<ResultType<Void>> {

    var root: UINavigationController! { get }
    var result: PublishSubject<ResultType<Void>> { get }
    // var loginResult: PublishSubject<ResultType<Void>> { get }
    // var welcomeResult: PublishSubject<ResultType<Void>> { get }
    var b2cOnboardingResult: PublishSubject<ResultType<Void>> { get }

    func login()
    //func welcome()
    func b2cOnboarding()
}

extension AccountSelectionCoordinatorType {
    /*
    func welcome() {
//        coordinate(to: B2CKYCCoordinator(root: root)).subscribe().disposed(by: rx.disposeBag)
        
        coordinate(to: WelcomeCoordinator(navigationController: self.root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.welcomeResult.onNext(result)
            })
            .disposed(by: rx.disposeBag)
    }
    */

    /*
    public func b2cOnboarding() {
//        coordinate(to: HouseholdOnBoardingCoordinator(navigationController: self.root))
        coordinate(to: B2COnBoardingCoordinator(navigationController: self.root))
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.b2cOnboardingResult.onNext(result)
            })
            .disposed(by: rx.disposeBag)
    }
    */

}
