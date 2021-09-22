//
//  VerifyPasscodeCoordinator.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import Foundation
import RxSwift
import YAPCore
import UIKit

enum PasscodeVerificationResult {
    case onboarding
    case dashboard(session: Session)
    case cancel
}

protocol PasscodeCoordinatorType: Coordinator<PasscodeVerificationResult> {

    var root: UINavigationController! { get }
    var container:YAPPakistanMainContainer! { get }
    var result: PublishSubject<PasscodeVerificationResult> { get }

}

class PasscodeCoordinator: Coordinator<PasscodeVerificationResult>, PasscodeCoordinatorType {
    
    var root: UINavigationController!
    var container: YAPPakistanMainContainer!
    var result = PublishSubject<PasscodeVerificationResult>()

    init(root: UINavigationController,
         xsrfToken: String,
         container: YAPPakistanMainContainer
    ){
        self.root = root
        self.container = container
        self.container.xsrfToken = xsrfToken
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<PasscodeVerificationResult> {
        
        let sessionCreator = SessionProvider(xsrfToken: container.xsrfToken)
        let viewModel = container.makeVerifyPasscodeViewModel(repository: container.makeLoginRepository(), sessionCreator: sessionCreator)
        
        let loginViewController = container.makePINViewController(viewModel: viewModel)

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.result
            .filter { $0.isSuccess?.optRequired ?? true}
            .subscribe(onNext: { [weak self] _ in
                self?.optVerification()
            }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.result
            .filter { $0.isSuccess?.session != nil }
            .map { $0.isSuccess?.session }.unwrap()
            .withUnretained(self)
            .subscribe(onNext: {
                $0.0.result.onNext(.dashboard(session: $0.1))
                $0.0.result.onCompleted()
                // root.popViewController(animated: true)
            }).disposed(by: rx.disposeBag)

        return result
    }
    
    func optVerification() {
        
        coordinate(to: LoginOPTCoordinator(root: root, xsrfToken: container.xsrfToken, container: container))
            .subscribe(onNext: { [weak self] result in switch result {
                case .cancel:
                    self?.root.popViewController(animated: true)
                    self?.result.onNext(.cancel)
                    self?.result.onCompleted()
                default: break
            }}).disposed(by: rx.disposeBag)
    }
    
}
