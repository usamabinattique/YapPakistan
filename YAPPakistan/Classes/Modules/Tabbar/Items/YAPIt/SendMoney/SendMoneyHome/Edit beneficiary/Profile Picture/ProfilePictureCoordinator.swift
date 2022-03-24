//
//  ProfilePictureCoordinator.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 22/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import UIKit

enum PictureReviewResult {
    case uploaded(String)
    case retake
}

class ProfilePictureCoordinator: Coordinator<ResultType<PictureReviewResult>> {
    
    private let root: UIViewController
    private let image: UIImage
    private let beneficiary: SendMoneyBeneficiary
    private let container: UserSessionContainer!
    private var localRoot: UINavigationController!
    
    private let result = PublishSubject<ResultType<PictureReviewResult>>()
    
    public init(root: UIViewController, container: UserSessionContainer, image: UIImage, beneficiary: SendMoneyBeneficiary) {
        
        self.root = root
        self.container = container
        self.image = image
        self.beneficiary = beneficiary
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<PictureReviewResult>> {
        
        let viewController = container.makeProfilePictureViewController(image: self.image, beneficiary: self.beneficiary)
        
        localRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localRoot.setNavigationBarHidden(true, animated: false)
        localRoot.modalPresentationStyle = .fullScreen
        root.present(localRoot, animated: true, completion: nil)
        
        viewController.viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewController.viewModel.outputs.result.subscribe(onNext: { [weak self] status in
            self?.localRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.success(status))
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        return result
    }
}
