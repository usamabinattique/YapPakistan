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
    private let container: YAPPakistanMainContainer
    private let xsrfToken: String

    internal weak var root: UINavigationController!
    private var containerNavigation: UINavigationController!
    private var childContainerNavigation: UINavigationController!
    private var disposable: Disposable!
    private var containerViewModel: OnBoardingContainerViewModel!
    private var viewModel: OnBoardingViewModel!

    private let resultSubject = PublishSubject<ResultType<Void>>()
    private let demographicsResultSubject = PublishSubject<Void>()

    public init(container: YAPPakistanMainContainer,
                xsrfToken: String,
                navigationController: UINavigationController) {
        self.container = container
        self.xsrfToken = xsrfToken
        self.root = navigationController
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

        let viewController = OnBoardingViewController(themeService: container.themeService, viewModel: viewModel, withChildNavigation: containerNavigation)

        root.pushViewController(viewController, animated: true)
        root.isNavigationBarHidden = true

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
}

// MARK: Navigation

private extension B2COnBoardingCoordinator {

    func navigateToPhoneNumber(user: OnBoardingUser) {
        let onBoardingRepository = OnBoardingRepository(customersService: container.makeCustomersService(xsrfToken: xsrfToken), messagesService: container.makeMessagesService(xsrfToken: xsrfToken))

        let phoneNumberViewModel = PhoneNumberViewModel(onBoardingRepository: onBoardingRepository, user: user)
        let phoneNumberViewController = PhoneNumberViewController(themeService: container.themeService, viewModel: phoneNumberViewModel)
        childContainerNavigation = OnBoardingContainerNavigationController(themeService: container.themeService, rootViewController: phoneNumberViewController)
        childContainerNavigation.navigationBar.isHidden = true

        phoneNumberViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: rx.disposeBag)

        phoneNumberViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: rx.disposeBag)

        phoneNumberViewModel.outputs.validInput.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: rx.disposeBag)

        containerViewModel.outputs.send.bind(to: phoneNumberViewModel.inputs.sendObserver).disposed(by: rx.disposeBag)

        phoneNumberViewModel.outputs.result.subscribe(onNext: {[unowned self] result in
            self.navigateToPhoneNumberVerification(user: result)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToPhoneNumberVerification(user: OnBoardingUser) {
        let onBoardingRepository = OnBoardingRepository(customersService: container.makeCustomersService(xsrfToken: xsrfToken), messagesService: container.makeMessagesService(xsrfToken: xsrfToken))

        let verificationViewModel = PhoneNumberVerificationViewModel(onBoardingRepository: onBoardingRepository, user: user)
        let phoneNumberVerificationController = PhoneNumberVerificationViewController(themeService: container.themeService, viewModel: verificationViewModel)
        childContainerNavigation.pushViewController(phoneNumberVerificationController, animated: true)

        verificationViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: rx.disposeBag)

        verificationViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: rx.disposeBag)

        verificationViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: rx.disposeBag)

        containerViewModel.outputs.send.bind(to: verificationViewModel.inputs.sendObserver).disposed(by: rx.disposeBag)

        verificationViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            self.navigateToCreatePasscode(user: result)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToCreatePasscode(user: OnBoardingUser) {
        let createPasscodeViewModel = CreatePasscodeViewModel()
        let createPasscodeViewController = PINViewController(themeService: container.themeService, viewModel: createPasscodeViewModel)
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: createPasscodeViewController)
        nav.modalPresentationStyle = .fullScreen
        root.present(nav, animated: true, completion: nil)
        var u = user

        createPasscodeViewModel.outputs.openTermsAndCondtions.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            // self.coordinate(to: TermsAndConditionCoordinator(root: nav)).subscribe().disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)

        createPasscodeViewModel.outputs.back.subscribe { [weak nav, weak self]_ in
            nav?.dismiss(animated: true, completion: {
                self?.childContainerNavigation.popViewController(animated: true)
            })
        }.disposed(by: rx.disposeBag)

        createPasscodeViewModel.result.subscribe(onNext: { [unowned self] result in
            nav.dismiss(animated: true, completion: nil)
            // AppAnalytics.shared.logEvent(OnBoardingEvent.passcodeCreated())
            // AppAnalytics.shared.logEvent(OnBoardingEvent.createPin())
            u.passcode = result
            self.navigateToEnterName(user: u)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToEnterName(user: OnBoardingUser) {
        let enterNameViewModel = EnterNameViewModel(user: user)
        childContainerNavigation.popViewController(animated: false)?.didPopFromNavigationController()
        childContainerNavigation.pushViewController(EnterNameViewController(themeService: container.themeService, viewModel: enterNameViewModel), animated: false)

        enterNameViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: rx.disposeBag)

        enterNameViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: rx.disposeBag)

        enterNameViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: rx.disposeBag)

        containerViewModel.outputs.send.bind(to: enterNameViewModel.inputs.sendObserver).disposed(by: rx.disposeBag)

        enterNameViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            self.navigateToEnterEmail(user: result)
            // AppAnalytics.shared.logEvent(OnBoardingEvent.signupName())
        }).disposed(by: rx.disposeBag)
    }

    func navigateToEnterEmail(user: OnBoardingUser) {
        let enterEmailViewController = container.makeEnterEmailController(xsrfToken: xsrfToken, user: user)
        let enterEmailViewModel: EnterEmailViewModelType! = enterEmailViewController.viewModel

        childContainerNavigation.pushViewController(enterEmailViewController, animated: true)

        enterEmailViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: rx.disposeBag)

        enterEmailViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: rx.disposeBag)

        enterEmailViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: rx.disposeBag)

        containerViewModel.outputs.send.bind(to: enterEmailViewModel.inputs.sendObserver).disposed(by: rx.disposeBag)

        enterEmailViewModel.outputs.deviceRegistration.subscribe(onNext: { [unowned self] _ in
            // self.postDemographicsInformation()
        }).disposed(by: rx.disposeBag)

        demographicsResultSubject.bind(to: enterEmailViewModel.inputs.demographicsSuccessObserver).disposed(by: rx.disposeBag)

        enterEmailViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            var user = result.user
            user.timeTaken = self.viewModel.time
            //user.isWaiting == true ?
            self.navigateToWaitingUserCongratulation(user: user, session: result.session)
            //: self.navigateToCongratulation(user: user)
                // AppAnalytics.shared.logEvent(OnBoardingEvent.signupEmailSuccess())
        }).disposed(by: rx.disposeBag)
    }

    func navigateToCongratulation(user: OnBoardingUser) {
        let congratulationViewModel: OnboardingCongratulationViewModelType = OnboardingCongratulationViewModel(user: user)
        let congratulationViewController = OnboardingCongratulationViewController(themeService: container.themeService, viewModel: congratulationViewModel)
        congratulationViewModel.outputs.stage.bind(to: containerViewModel.inputs.activeStageObserver).disposed(by: rx.disposeBag)

        containerNavigation.pushViewController(congratulationViewController, animated: true)

        congratulationViewModel.outputs.completeVerification.subscribe(onNext: { [weak self] _ in
            /// self?.b2cKyc()
            // AppAnalytics.shared.logEvent(OnBoardingEvent.completeVerification())
        }).disposed(by: rx.disposeBag)
    }
    
    func navigateToWaitingUserCongratulation(user: OnBoardingUser, session: Session) {
        let congratulationViewModel: OnboardingCongratulationViewModelType = OnboardingCongratulationViewModel(user: user)
        let congratulationViewController = OnboardingCongratulationWaitingUserViewController(themeService: container.themeService, viewModel: congratulationViewModel)
        congratulationViewModel.outputs.stage.bind(to: containerViewModel.inputs.activeStageObserver).disposed(by: rx.disposeBag)

        // #warning("Progress marked completed!")
        // self.viewModel.inputs.progressObserver.onNext(1)

        containerNavigation.pushViewController(congratulationViewController, animated: true)

        congratulationViewModel.outputs.completeVerification.subscribe(onNext: { [weak self] _ in
            self?.navigateToWaitingListRank(session: session)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToWaitingList(_ waitingListNumber: Int) {
        let waitingListViewModel = OnBoardingWaitingListViewModel(waitingListNumber)
        let waitingListViewController = OnBoardingWaitingListViewController(viewModel: waitingListViewModel)

        containerNavigation.pushViewController(waitingListViewController, animated: true)

        waitingListViewModel.outputs.keepMePosted.subscribe(onNext: {
            UIApplication.shared.open($0, options: [:], completionHandler: nil)
        }).disposed(by: rx.disposeBag)
    }

    func navigateToWaitingListRank(session: Session) {
        let sessionContainer = UserSessionContainer(parent: container, session: session)
        let window = root.view.window ?? UIWindow()
        let coordinator = WaitingListRankCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to on boarding")
        }).disposed(by: rx.disposeBag)
    }

    /*
     func postDemographicsInformation() {
     let viewModel = DeviceRegistrationViewModel(credentials: nil, action: .signup, otpVerificationToken: nil)
     let viewController = DeviceRegistrationViewController(viewModel: viewModel)
     viewController.modalPresentationStyle = .overCurrentContext
     root.present(viewController, animated: false, completion: nil)
     
     viewModel.outputs.error.subscribe(onNext: { [weak self] error in
     viewController.dismiss(animated: false, completion: nil)
     self?.root.rx.showErrorMessage.onNext(error)
     }).disposed(by: rx.disposeBag)
     
     viewModel.outputs.success.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
     viewController.dismiss(animated: false, completion: nil)
     self?.demographicsResultSubject.onNext(())
     }).disposed(by: rx.disposeBag)
     }
     
     func b2cKyc() {
     coordinate(to: B2CKYCCoordinatorPushable(root: self.root))
     .subscribe(onNext: { [weak self] res in
     self?.resultSubject.onNext(res)
     self?.resultSubject.onCompleted()
     }).disposed(by: self.rx.disposeBag)
     }
     
     func waitingRank() {
     coordinate(to: OnboardingWaitingListRankCoordinator(window: UIWindow.keyWindow, repository: AccountRepository()))
     .subscribe(onNext: { [weak self] _ in
     self?.resultSubject.onNext(.success(()))
     self?.resultSubject.onCompleted()
     }).disposed(by: self.rx.disposeBag)
     }
     */

    // MARK: Bump me up the queue - Invite Friends using Adjust
    private func bumpMeUpTheQueue() {

    }
}
