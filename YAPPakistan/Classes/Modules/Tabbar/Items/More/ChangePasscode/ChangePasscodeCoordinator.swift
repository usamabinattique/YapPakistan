//
//  ChangePasscodeCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 27/04/2022.
//

import Foundation

import Foundation
import YAPComponents
import RxSwift
import YAPCore


public class ChangePasscodeCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    
    public init(root: UINavigationController!, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = ChangePasscodeViewModel(repository: self.container.makeLoginRepository())
        let viewController: ChangePasscodeViewController = ChangePasscodeViewController(themeService: self.container.themeService, viewModel: viewModel) //PINViewController(themeService: self.container.themeService, viewModel: createPasscodeViewModel)
        localRoot = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        localRoot.modalPresentationStyle = .fullScreen
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
}

