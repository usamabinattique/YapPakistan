//
//  OnBoardingCoordinator.swift
//  YAP
//
//  Created by Zain on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import YAPCore
import YAPComponents

public class B2COnBoardingCoordinator: Coordinator<ResultType<Void>> {

    private let container: DemoApplicationContainer

    var root: UINavigationController!
    weak var window: UIWindow?
    private var containerNavigation: UINavigationController!
    private var childContainerNavigation: UINavigationController!
    private var disposable: Disposable!
    private var containerViewModel: OnBoardingContainerViewModel!
    private var viewModel: OnBoardingViewModel!

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let demographicsResultSubject = PublishSubject<Void>()

    init(container: DemoApplicationContainer,
         window: UIWindow) {
        self.container = container
        self.window = window
    }

    deinit {
        print("B2COnBoardingCoordinator")
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        viewModel = OnBoardingViewModel()
        containerViewModel = OnBoardingContainerViewModel()

        navigateToPhoneNumber(user: OnBoardingUser(accountType: .b2cAccount))

        let containerView = OnBoardingContainerViewController(themeService: container.themeService, viewModel: containerViewModel, childNavigation: childContainerNavigation)
        containerNavigation = UINavigationController(rootViewController: containerView)
        containerNavigation.navigationBar.isHidden = true
        containerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        childContainerNavigation.interactivePopGestureRecognizer?.isEnabled = false

        let viewController = OnBoardingViewController(themeService: container.themeService,
                                                      viewModel: viewModel,
                                                      withChildNavigation: containerNavigation)

        root = UINavigationController(rootViewController: viewController)
        root.interactivePopGestureRecognizer?.isEnabled = false
        root.navigationBar.setBackgroundImage(UIImage(), for: .default)
        root.navigationBar.shadowImage = UIImage()
        root.navigationBar.isTranslucent = true
        root.navigationBar.isHidden = true

        self.window!.rootViewController = self.root

        viewModel.backTap.do(onNext: { [weak self] in
            if self?.childContainerNavigation.viewControllers.count ?? 0 > 1 {
                self?.childContainerNavigation.popViewController(animated: true)?.didPopFromNavigationController()
            } else if self?.containerNavigation.viewControllers.count ?? 0 > 1 {
                self?.containerNavigation.popViewController(animated: true)
            } else {
                self?.root.popViewController(animated: true)?.didPopFromNavigationController()
                self?.resultSubject.onNext(ResultType.cancel)
                self?.resultSubject.onCompleted()
            }
        }).subscribe().disposed(by: rx.disposeBag)

        return resultSubject
    }

    func navigateToPhoneNumber(user: OnBoardingUser) {
        let phoneNumberViewController = container.makePhoneNumberViewController(user: user)
        childContainerNavigation = OnBoardingContainerNavigationController(themeService: container.themeService, rootViewController: phoneNumberViewController)
        childContainerNavigation.navigationBar.isHidden = true

        let phoneNumberViewModel = phoneNumberViewController.viewModel
        phoneNumberViewModel!.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: rx.disposeBag)

        phoneNumberViewModel!.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: rx.disposeBag)

        phoneNumberViewModel!.outputs.validInput.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: rx.disposeBag)

        containerViewModel.outputs.send.bind(to: phoneNumberViewModel!.inputs.sendObserver).disposed(by: rx.disposeBag)

        phoneNumberViewModel!.outputs.result.subscribe(onNext: {[unowned self] result in
            startLocalOnboardingFlow(onboardingUser: result)
        }).disposed(by: rx.disposeBag)
    }

    func startLocalOnboardingFlow(onboardingUser: OnBoardingUser) {
        self.coordinate(to: container.makePKAppCoordinator(window: window!,
                                                           navigationController: root,
                                                           formattedPhoneNumber: onboardingUser.mobileNo.formattedValue,
                                                           onboarding: true))
            .subscribe()
            .disposed(by: rx.disposeBag)
    }
}
