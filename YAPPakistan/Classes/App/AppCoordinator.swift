//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
import RxSwift
import NSObject_Rx
import YAPCore

public class AppCoordinator: Coordinator<ResultType<Void>> {
    
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    private let result = PublishSubject<ResultType<Void>>()
    private let container: YAPPakistanMainContainer
    let reposiotry = SplashRepository(service: XSRFService())
    
    public init(window:UIWindow,
                shortcutItem: UIApplicationShortcutItem?,
                container: YAPPakistanMainContainer) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.container = container
        super.init()
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let _ = reposiotry.fetchXSRFToken().subscribe().disposed(by: rx.disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showDummyController()
        }
        return result
    }
    
    func showDummyController() {
        if let value = HTTPCookieStorage.shared.cookies?.filter({ $0.name == "XSRF-TOKEN" }).first?.value {
            // start onboarding, signin, signup flow
            let vc = container.makeDummyViewController(xsrfToken: value)
        }
    }
    
}
