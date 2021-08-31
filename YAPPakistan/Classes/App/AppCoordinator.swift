//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
//import YAPKit
import RxSwift
//import Authentication
//import OnBoarding
//import Networking
//import YAPKit
//import YAPb2b

class AppCoordinator:Coordinator<ResultType<Void>> {
    private let window: UIWindow
    private let router:Router<AuthScene>
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    
    init(window:UIWindow, shortcutItem:UIApplicationShortcutItem?, router:Router<AuthScene>) {
        self.window = window
        self.router = router
        self.shortcutItem = shortcutItem
        super.init()
    }
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        return Observable<ResultType<Void>>.create { observer in
            
            Disposables.create()
        }
    }
    /*
    func splash(shortcutItem: UIApplicationShortcutItem?) {
        self.coordinate(to: SplashCoordinator(window: window,
                                              shortcutItem: shortcutItem,
                                              store: CredentialsManager(),
                                              repository: SplashRepository(service: XSRFService() )))
            .subscribe(onNext: { [unowned self] result in
                self.splashResult.onNext(result)
            })
            .disposed(by: disposeBag)
    }
    */
}
