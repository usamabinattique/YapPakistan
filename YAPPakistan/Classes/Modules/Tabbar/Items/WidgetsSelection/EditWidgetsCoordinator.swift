//
//  EditWidgetsCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
//import OnBoarding
//import AppDatabase
import YAPCardScanner
//import More
//import Cards
//import AppAnalytics


public class EditWidgetsCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UITabBarController
    private let hideWidgetsResult = PublishSubject<Void>()
    private let widgetSelectionSwitchResult = PublishSubject<Void>()
    private let result = PublishSubject<ResultType<Void>>()
    private let disposeBag = DisposeBag()
    private let container: UserSessionContainer
    
    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }
//    public init(root: UINavigationController, container: UserSessionContainer) {
//        self.root = root
//        self.container = container
//    }
//
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = WidgetSelectionViewModel(accountProvider: container.accountProvider,cardsRepository: container.makeCardsRepository(), themeService: container.themeService)
        let viewController = WidgetSelectionViewController(themeService: container.themeService, viewModel: viewModel)
        let nav = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        root.present(nav, animated: true, completion: nil)
        
        viewModel.isSwitchOn.subscribe(onNext: {[weak self]  value in
            if (value ?? false) {
                self?.openPopup()
            }
        }).disposed(by: disposeBag)
        
        widgetSelectionSwitchResult.bind(to: viewModel.cancelClickObserver).disposed(by: disposeBag)

        viewModel.back.subscribe(onNext: {[weak self] val in
            if val {
                self?.result.onNext(.success(()))
            }
            else {
                self?.result.onNext(.cancel)
            }
            self?.root.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        hideWidgetsResult.subscribe(onNext: {[weak self] in
            self?.root.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        return result
    }
    
    func openPopup() {
       /* let viewModel = HideWidgetPopupViewModel()
        let viewController = HideWidgetPopupViewController(viewModel: viewModel)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = YAPActionSheetRootViewController()
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)
        viewController.window = alertWindow
        viewModel.cancel.subscribe(onNext: {
            nav.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        viewModel.hideWidget.subscribe(onNext: {
            nav.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        viewModel.hideWidget.bind(to: hideWidgetsResult).disposed(by: disposeBag)
        viewModel.cancel.bind(to: widgetSelectionSwitchResult).disposed(by: disposeBag) */
    }
}
