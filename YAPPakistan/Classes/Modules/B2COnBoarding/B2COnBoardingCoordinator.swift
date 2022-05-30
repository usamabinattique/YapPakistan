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


final class B2COnBoardingCoordinator: Coordinator<ResultType<Void>> {

    private let container: OnboardingContainer
    weak var root: UINavigationController!
    private var containerNavigation: UINavigationController!
    private var childContainerNavigation: UINavigationController!
    private var containerViewModel: OnBoardingContainerViewModel!
    private var viewModel: OnBoardingViewModel!

    private let result = PublishSubject<ResultType<Void>>()
    private let demographicsResultSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    public init(container: OnboardingContainer,
                navigationController: UINavigationController) {
        self.container = container
        self.root = navigationController
    }

    deinit {
        print("B2COnBoardingCoordinator")
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        viewModel = OnBoardingViewModel()
        containerViewModel = OnBoardingContainerViewModel()

        navigateToPhoneNumberVerification(user: container.user)

        let containerView = OnBoardingContainerViewController(themeService: container.parent.themeService,
                                                              viewModel: containerViewModel,
                                                              childNavigation: childContainerNavigation)

        containerNavigation = UINavigationController(rootViewController: containerView)
        containerNavigation.navigationBar.isHidden = true
        containerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        childContainerNavigation.interactivePopGestureRecognizer?.isEnabled = false

        let viewController = OnBoardingViewController(themeService: container.parent.themeService,
                                                      viewModel: viewModel,
                                                      withChildNavigation: containerNavigation)

        root.pushViewController(viewController, animated: true)

        viewModel.backTap.do(onNext: { [weak self] in
            if self?.childContainerNavigation.viewControllers.count ?? 0 > 1 {
                self?.childContainerNavigation.popViewController(animated: true)?.didPopFromNavigationController()
            } else if self?.containerNavigation.viewControllers.count ?? 0 > 1 {
                self?.containerNavigation.popViewController(animated: true)
            } else {
                self?.root.popViewController(animated: true)?.didPopFromNavigationController()
                self?.result.onNext(ResultType.cancel)
                self?.result.onCompleted()
            }
        }).subscribe().disposed(by: disposeBag)

        return result
    }
}

// MARK: Navigation

private extension B2COnBoardingCoordinator {

    func navigateToPhoneNumberVerification(user: OnBoardingUser) {
        let onBoardingRepository = OnBoardingRepository(customersService: container.parent.makeCustomersService(),
                                                        messagesService: container.parent.makeMessagesService())
        let verificationViewModel = PhoneNumberVerificationViewModel(onBoardingRepository: onBoardingRepository,
                                                                     user: user)
        let phoneVerificationController = PhoneNumberVerificationViewController(themeService: container.parent.themeService,
                                                                                viewModel: verificationViewModel)


        childContainerNavigation = OnBoardingContainerNavigationController(themeService: container.parent.themeService,
                                                                           rootViewController: phoneVerificationController)
        childContainerNavigation.navigationBar.isHidden = true

        verificationViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)

        verificationViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: disposeBag)

        verificationViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: disposeBag)

        containerViewModel.outputs.send.bind(to: verificationViewModel.inputs.sendObserver).disposed(by: disposeBag)

        verificationViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            //TODO: uncomment following
            self.navigateToCreatePasscode(user: result)
            
//            //TODO: remove following line
//            var newResult = result
//            newResult.timeTaken = 15
//            self.navigateToWaitingUserCongratulation(user: newResult, session: Session(sessionToken: " abc "))
        }).disposed(by: disposeBag)
    }

    func navigateToCreatePasscode(user: OnBoardingUser) {
        let createPasscodeViewModel = CreatePasscodeViewModel()
        let createPasscodeViewController = PINViewController(themeService: container.parent.themeService, viewModel: createPasscodeViewModel)
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: createPasscodeViewController)
        nav.modalPresentationStyle = .fullScreen
        root.present(nav, animated: true, completion: nil)
        var u = user

        createPasscodeViewModel.outputs.openTermsAndCondtions.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            // self.coordinate(to: TermsAndConditionCoordinator(root: nav)).subscribe().disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        createPasscodeViewModel.outputs.back.subscribe { [weak nav, weak self]_ in
            nav?.dismiss(animated: true, completion: {
                self?.childContainerNavigation.popViewController(animated: true)
            })
        }.disposed(by: disposeBag)

        createPasscodeViewModel.result.subscribe(onNext: { [unowned self] result in
            nav.dismiss(animated: true, completion: nil)
            // AppAnalytics.shared.logEvent(OnBoardingEvent.passcodeCreated())
            // AppAnalytics.shared.logEvent(OnBoardingEvent.createPin())
            u.passcode = result
            self.navigateToEnterName(user: u)
        }).disposed(by: disposeBag)
    }

    func navigateToEnterName(user: OnBoardingUser) {
        let enterNameViewModel = EnterNameViewModel(user: user)
        childContainerNavigation.popViewController(animated: false)?.didPopFromNavigationController()
        childContainerNavigation.pushViewController(EnterNameViewController(themeService: container.parent.themeService, viewModel: enterNameViewModel), animated: false)

        enterNameViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)

        enterNameViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: disposeBag)

        enterNameViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: disposeBag)

        containerViewModel.outputs.send.bind(to: enterNameViewModel.inputs.sendObserver).disposed(by: disposeBag)

        enterNameViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            self.navigateToEnterEmail(user: result)
            // AppAnalytics.shared.logEvent(OnBoardingEvent.signupName())
        }).disposed(by: disposeBag)
    }

    func navigateToEnterEmail(user: OnBoardingUser) {
        let enterEmailViewController = container.makeEnterEmailController(user: user)
        let enterEmailViewModel: EnterEmailViewModelType! = enterEmailViewController.viewModel

        childContainerNavigation.pushViewController(enterEmailViewController, animated: true)

        enterEmailViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            print("enter email progress \(progress)")
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)

        enterEmailViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            print("enter email progress \(stage)")
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: disposeBag)

        enterEmailViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: disposeBag)

        containerViewModel.outputs.send.bind(to: enterEmailViewModel.inputs.sendObserver).disposed(by: disposeBag)

        enterEmailViewModel.outputs.deviceRegistration.subscribe(onNext: { [unowned self] _ in
            // self.postDemographicsInformation()
        }).disposed(by: disposeBag)

        demographicsResultSubject.bind(to: enterEmailViewModel.inputs.demographicsSuccessObserver).disposed(by: disposeBag)

        enterEmailViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            var user = result.user
            user.timeTaken = self.viewModel.time
            user.isWaiting == true ?
            self.navigateToWaitingUserCongratulation(user: user, session: result.session)
            : self.navigateToCongratulation(user: user)
                // AppAnalytics.shared.logEvent(OnBoardingEvent.signupEmailSuccess())
        }).disposed(by: disposeBag)
    }

    func navigateToCongratulation(user: OnBoardingUser) {
        let congratulationViewModel: OnboardingCongratulationViewModelType = OnboardingCongratulationViewModel(user: user)
        let congratulationViewController = OnboardingCongratulationViewController(themeService: container.parent.themeService,
                                                                                  viewModel: congratulationViewModel)
        congratulationViewModel.outputs.stage.bind(to: containerViewModel.inputs.activeStageObserver).disposed(by: disposeBag)

        containerNavigation.pushViewController(congratulationViewController, animated: true)

        congratulationViewModel.outputs.progress.subscribe(onNext: { [weak self] progress in
            self?.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.animationCompleted.subscribe(onNext: {  _ in
            print("animation completed call in B@COn")
            congratulationViewController.resumeAnimation?()
        }).disposed(by: disposeBag)
        
        congratulationViewModel.outputs.completeVerification.subscribe(onNext: { [weak self] _ in
            /// self?.b2cKyc()
            // AppAnalytics.shared.logEvent(OnBoardingEvent.completeVerification())
        }).disposed(by: disposeBag)
    }
    
    func navigateToWaitingUserCongratulation(user: OnBoardingUser, session: Session) {
        let congratulationViewModel: OnboardingCongratulationViewModelType = OnboardingCongratulationViewModel(user: user)
        let congratulationViewController = OnboardingCongratulationWaitingUserViewController(themeService: container.parent.themeService, viewModel: congratulationViewModel)
        congratulationViewModel.outputs.stage.bind(to: containerViewModel.inputs.activeStageObserver).disposed(by: disposeBag)

        // #warning("Progress marked completed!")
        // self.viewModel.inputs.progressObserver.onNext(1)
        
        congratulationViewModel.outputs.progress.subscribe(onNext: { [weak self] progress in
            self?.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.animationCompleted.subscribe(onNext: {  _ in
            print("animation completed call in B@COn")
            congratulationViewController.resumeAnimation?()
        }).disposed(by: disposeBag)

        
        containerNavigation.pushViewController(congratulationViewController, animated: true)

        congratulationViewModel.outputs.completeVerification.subscribe(onNext: { [weak self] _ in
            self?.navigateToWaitingListRank(session: session)
        }).disposed(by: disposeBag)
    }

    func navigateToWaitingList(_ waitingListNumber: Int) {
        let waitingListViewModel = OnBoardingWaitingListViewModel(waitingListNumber)
        let waitingListViewController = OnBoardingWaitingListViewController(viewModel: waitingListViewModel)

        containerNavigation.pushViewController(waitingListViewController, animated: true)

        waitingListViewModel.outputs.keepMePosted.subscribe(onNext: {
            UIApplication.shared.open($0, options: [:], completionHandler: nil)
        }).disposed(by: disposeBag)
    }

    func navigateToWaitingListRank(session: Session) {
        let sessionContainer = UserSessionContainer(parent: container.parent, session: session)
        let window = root.view.window ?? UIWindow()
        let coordinator = WaitingListRankCoordinator(container: sessionContainer, window: window)

        coordinate(to: coordinator).subscribe(onNext: { _ in
            print("Moved to on boarding")
        }).disposed(by: disposeBag)
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
     }).disposed(by: disposeBag)
     
     viewModel.outputs.success.delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
     viewController.dismiss(animated: false, completion: nil)
     self?.demographicsResultSubject.onNext(())
     }).disposed(by: disposeBag)
     }
     
     func b2cKyc() {
     coordinate(to: B2CKYCCoordinatorPushable(root: self.root))
     .subscribe(onNext: { [weak self] res in
     self?.resultSubject.onNext(res)
     self?.resultSubject.onCompleted()
     }).disposed(by: self.disposeBag)
     }
     
     func waitingRank() {
     coordinate(to: OnboardingWaitingListRankCoordinator(window: UIWindow.keyWindow, repository: AccountRepository()))
     .subscribe(onNext: { [weak self] _ in
     self?.resultSubject.onNext(.success(()))
     self?.resultSubject.onCompleted()
     }).disposed(by: self.disposeBag)
     }
     */

    // MARK: Bump me up the queue - Invite Friends using Adjust
    private func bumpMeUpTheQueue() {

    }
}
