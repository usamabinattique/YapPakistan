//
//  LoginCoordinatorType.swift
//  App
//
//  Created by Hussaan S on 24/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore

enum LoginResult {
    case onboarding
    case dashboard(session: Session)
    case cancel
}

protocol LoginCoordinatorType: Coordinator<LoginResult> {

    var root: UINavigationController!           { get }
    var container: YAPPakistanMainContainer!     { get }
    var result: PublishSubject<LoginResult>     { get }

}
