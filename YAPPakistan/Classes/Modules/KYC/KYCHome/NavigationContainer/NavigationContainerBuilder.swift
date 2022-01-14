//
//  NavigationContainerBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/12/2021.
//

import Foundation

struct NavigationContainerBuilder {
    var navigation: UINavigationController
    var container: YAPPakistanMainContainer
    func viewController() -> NavigationContainerViewController {
        let viewController = NavigationContainerViewController(withChildNavigation: navigation)
        return viewController
    }
}
