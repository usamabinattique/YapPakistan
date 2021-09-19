//
//  WelcomeCoordinator.swift
//  YAP
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import YAPCore

public class WelcomeCoordinator: Coordinator<ResultType<Void>> {
    public weak var root: UINavigationController!

    public init(navigationController: UINavigationController) {
        self.root = navigationController
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewController = WelcomeViewController()
        let viewModel = WelcomeViewModel()
        viewController.viewModel = viewModel

        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        root.present(nav, animated: true, completion: nil)

        return viewModel.outputs.getStarted.flatMap { [unowned self] _ -> Observable<ResultType<Void>> in
            self.root.dismiss(animated: true, completion: nil)
            return Observable.just(ResultType.success(()))
        }
    }
}
