//
//  DemoAppCoordinator.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore

public class DemoAppCoordinator: Coordinator<ResultType<Void>> {
    
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    private let result = PublishSubject<ResultType<Void>>()
    private let container: DemoApplicationContainer = DemoApplicationContainer(store: CredentialsManager())
    
    public init(window:UIWindow, shortcutItem:UIApplicationShortcutItem?) {
        self.window = window
        self.shortcutItem = shortcutItem
        super.init()
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        self.splash(shortcutItem: nil)
        return result
    }
    
}

extension DemoAppCoordinator {
    
    func splash(shortcutItem: UIApplicationShortcutItem?) {
        self.coordinate(to: container.makeSplashCoordinator(window: window))
            .subscribe(onNext: { [weak self] result in
            self?.handleSplashResponse(result: result)
        })
        .disposed(by: rx.disposeBag)
    }
    
    private func handleSplashResponse(result: ResultType<NavigationType>) {
        guard let result = result.isSuccess else { return }
        switch result {
            case .login:
                startApplication()
            case .passcode:
                startApplication()
            case .onboarding:
                startApplication()
        }
    }
    
    private func startApplication() {
        self.coordinate(to: container.makePKApplication(window: window)).subscribe(onNext: { result in
            switch result {
            case .success:
                self.result.onNext(.success(()))
                self.result.onCompleted()
            case .cancel:
                ()
            }
        }).disposed(by: rx.disposeBag)
    }
    
}
