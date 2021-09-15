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
    
    var container: YAPPakistanMainContainer
    var root: UINavigationController
    var permissionType: SystemPermissionType
    let account: Observable<Account?>
    
    public init(container: YAPPakistanMainContainer, root: UINavigationController, type: SystemPermissionType, account: Observable<Account?>) {
        self.container = container
        self.root = root
        self.permissionType = type
        self.account = account
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<Void> {
        let viewModel: SystemPermissionViewModelType = SystemPermissionViewModel(permissionType: permissionType, account: self.account)
        let viewController = SystemPermissionViewController(themeService: container.themeService, viewModel: viewModel)
        
        root.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}
