//
//  VerifyPasscodeCoordinator.swift
//  Alamofire
//
//  Created by Sarmad on 20/09/2021.
//

import Foundation
import RxSwift
import YAPCore

enum PasscodeVerificationResult {
    case optVerification
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
        
        let viewModel = container.makeVerifyPasscodeViewModel(repository: container.makeLoginRepository())
        let loginViewController = container.makeVerifyPasscodeViewController(viewModel: viewModel)

        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = false
        root.pushViewController(loginViewController, animated: true)
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.root.popViewController(animated: true)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] _ in
            // Navigate to OPT Verification
        }).disposed(by: rx.disposeBag)

        return result
    }
    
    func optVerification() {
        
    }
    
}
