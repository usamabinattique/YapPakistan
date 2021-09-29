//
//  PasscodeCoordinatorType.swift
//  YAPPakistan
//
//  Created by Sarmad on 24/09/2021.
//

import Foundation
import RxSwift
import YAPCore

protocol PasscodeCoordinatorType: Coordinator<PasscodeVerificationResult> {

    var root: UINavigationController! { get }
    var container:YAPPakistanMainContainer! { get }
    var result: PublishSubject<PasscodeVerificationResult> { get }

    func forgotOTPVerification()

}

extension PasscodeCoordinatorType {
    func forgotOTPVerification() {
        coordinate(to: container.makeForgotOTPCoordinator(root: root) )
            .subscribe(onNext: { result in
                
            })
            .disposed(by: rx.disposeBag)
    }
}
