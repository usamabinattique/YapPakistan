//
//  SystemPermissionCoordinator.swift
//  App
//
//  Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift

public enum SystemPermissionType: String {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case notification = "notification"
}

public class SystemPermissionCoordinator: Coordinator<Void> {
    
    var root: UINavigationController
    var permissionType: SystemPermissionType
    let account: Observable<Account?>
    
    public init(root: UINavigationController, type: SystemPermissionType, account: Observable<Account?>) {
        self.root = root
        self.permissionType = type
        self.account = account
    }
    
    public override func start() -> Observable<Void> {
        let viewModel: SystemPermissionViewModelType = SystemPermissionViewModel(permissionType: permissionType, account: self.account)
        let viewController = SystemPermissionViewController(viewModel: viewModel)
        
        root.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}
