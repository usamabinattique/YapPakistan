//
//  SystemPermissionCoordinator.swift
//  App
//
//  Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift
import YAPCore

public enum SystemPermissionType: String {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case notification = "notification"
}

public class SystemPermissionCoordinator: Coordinator<Void> {
    
    let root: UINavigationController
    let permissionType: SystemPermissionType
    let container: YAPPakistanMainContainer
    let account: Observable<Account?>?

    public init(root: UINavigationController,
                type: SystemPermissionType,
                account: Observable<Account?>?,
                container: YAPPakistanMainContainer) {
        self.root = root
        self.permissionType = type
        self.account = account
        self.container = container
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<Void> {
        let  notificationManager = NotificationManager()
        let viewModel = SystemPermissionViewModel(permissionType: permissionType,
                                                  account: self.account,
                                                  notificationManager: notificationManager)
        let viewController = SystemPermissionViewController(themeService: container.themeService,
                                                            viewModel: viewModel,
                                                            notificationManager: notificationManager)
        root.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}
