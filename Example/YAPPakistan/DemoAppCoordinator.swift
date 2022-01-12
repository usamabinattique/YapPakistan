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
import YAPPakistan

public class DemoAppCoordinator: Coordinator<ResultType<Void>> {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var shortcutItem: UIApplicationShortcutItem?
    private let result = PublishSubject<ResultType<Void>>()
    private let container: DemoApplicationContainer = DemoApplicationContainer(store: CredentialsManager())
    
    public init(window:UIWindow, shortcutItem: UIApplicationShortcutItem?) {
        self.window = window
        self.shortcutItem = shortcutItem
        self.navigationController = UINavigationController()
        super.init()

        //NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name("LOGOUT"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name.init(.logout), object: nil)
        
     //   NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name("authentication_required"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name.init(.authenticationRequired), object: nil)
    }

    @objc func logout() {
        result.onNext(.success(()))
        result.onCompleted()
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
                login()
            case .passcode:
                passcode(formattedPhoneNumber: container.store.getUsername())
            case .welcome:
                welcome()
        }
    }
    
    private func onboarding() {
        self.coordinate(to: container.makeOnBoardingCoodinator(window: window))
            .subscribe(onNext: { [unowned self] result in
            switch result {
            case .success:
                ()
            case .cancel:
                welcome()
            }
        }).disposed(by: rx.disposeBag)
    }

    private func welcome() {
        self.coordinate(to: container.makeWelcomeCoordinator(window: window))
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .signin:
                    login()
                case .signup:
                    onboarding()
                }
            })
            .disposed(by: rx.disposeBag)
    }

    private func login() {
        self.coordinate(to: container.makeLoginCoordinator(window: window))
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .signup:
                    welcome()
                case .cancel:
                    ()
                case .passcode(let formattedPhoneNumber):
                    passcode(formattedPhoneNumber: formattedPhoneNumber)
                }
            })
            .disposed(by: rx.disposeBag)
    }

    private func passcode(formattedPhoneNumber: String?) {
        self.coordinate(to: container.makePKAppCoordinator(window: window,
                                                           navigationController: navigationController!,
                                                           formattedPhoneNumber: formattedPhoneNumber,
                                                           onboarding: false))
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .cancel:
                    login()
                case .success:
                    ()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}
