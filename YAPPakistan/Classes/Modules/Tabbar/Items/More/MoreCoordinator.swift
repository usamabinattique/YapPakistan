//
//  MoreCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents
import YAPCore
import UIKit

public class MoreCoordinator: Coordinator<ResultType<UserProfileResult>> {

    private let root: UITabBarController
    private var localRoot: UINavigationController!
    private var navigationRoot: UINavigationController!
    private let result = PublishSubject<ResultType<UserProfileResult>>()
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    public init(root: UITabBarController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<UserProfileResult>> {

        let viewModel = MoreViewModel(accountProvider: container.accountProvider, repository: container.makeMoreRepository(), theme: container.themeService)
        let viewController = MoreViewController(viewModel: viewModel, themeService: container.themeService)
        navigationRoot = UINavigationController(rootViewController: viewController)
        navigationRoot.navigationBar.isHidden = false
        navigationRoot.tabBarItem = UITabBarItem(title: "More",
                                                 image: UIImage(named: "icon_tabbar_more", in: .yapPakistan),
                                                 selectedImage: nil)

        if root.viewControllers == nil {
            root.viewControllers = [navigationRoot]
        } else {
            root.viewControllers?.append(navigationRoot)
        }
        
        viewModel.outputs.openMoreItem.subscribe(onNext: { [unowned self] item in self.openMoreItem(item) }).disposed(by: disposeBag)
        
        
        viewModel.outputs.settings.subscribe(onNext: { [unowned self]  in
            openUserProfileSettings()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.bankDetails.subscribe(onNext: { [unowned self] in
            openAccountDetails()
        }).disposed(by: disposeBag)

        return result
    }

}

extension MoreCoordinator {
    
    func openAccountDetails() {
        
        let viewModel = MoreBankDetailsViewModel(accountProvider: container.accountProvider)
        let viewController = MoreBankDetailsViewController(themeService: container.themeService, viewModel: viewModel)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = YAPActionSheetRootViewController(nibName: nil, bundle: nil)
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        let nav = UINavigationController(rootViewController: viewController)

        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)

        viewController.window = alertWindow
    }
    
    func openUserProfileSettings() {
        coordinate(to: UserProfileCoordinator(root: root, container: self.container))
            .subscribe(onNext:{ _ in
            })
            .disposed(by: rx.disposeBag)

        
    }
    
    func openMoreItem(_ item: MoreCollectionViewCellViewModel.CellType) {
        switch item {
        case .inviteAFriend:
            print("inviteAFriend")
            inviteFriend()
        case .help:
            print("help")
            //help()
        case .termsAndConditions:
            print("termsAndConditions")
            //termsAndConditions()
        case .yapForYou:
            print("yapForYou")
            //navigateToYapForYou()
        default:
            break
        }
    }
    
    func inviteFriend() {
        let customerId = container.accountProvider.currentAccountValue.value?.customer.customerId
        let shareText = appShareMessageForMore(container.parent.referralManager.pkReferralURL(forInviter: customerId ?? ""))
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = root.view
        
        navigationRoot.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            
        }
    }
}
