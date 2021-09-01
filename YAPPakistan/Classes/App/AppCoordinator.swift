//
//  AppCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/08/2021.
//

import UIKit
import RxSwift
import NSObject_Rx

public class AppCoordinator:Coordinator<ResultType<Void>> {
    
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    
    public init(window:UIWindow, shortcutItem:UIApplicationShortcutItem?) {
        self.window = window
        
        self.shortcutItem = shortcutItem
        super.init()
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        print("HEllo")
        return Observable<ResultType<Void>>.create { [unowned self] observer in
            self.splash(shortcutItem: nil)
            return Disposables.create()
        }
    }
    
    func splash(shortcutItem: UIApplicationShortcutItem?) {
        self.coordinate(
            to: SplashCoordinator (
                window: window,
                shortcutItem: shortcutItem,
                store: CredentialsManager(),
                repository: SplashRepository(service: XSRFService() )
            )
        )
        .subscribe(onNext: { [weak self] result in
            self?.handleSplashResponse(result: result)
        })
        .disposed(by: rx.disposeBag)
    }
    
    private func handleSplashResponse(result:ResultType<NavigationType>) {
        guard let result = result.isSuccess else { return }
        switch result {
            case .login(let xsrfToken):
                print("login result: sxrfToken, \(xsrfToken)")
            case .passcode(let xsrfToken):
                print("passcode result: sxrfToken, \(xsrfToken)")
            case .onboarding(let xsrfToken):
                print("onboarding result: sxrfToken, \(xsrfToken)")
        }
    }
}
