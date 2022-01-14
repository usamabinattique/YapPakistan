//
//  NavigationControllerBuilder.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/12/2021.
//

import UIKit

struct NavigationControllerBuilder {

    var root: UIViewController? = nil
    var isInteractivePopGesture: Bool = false
    var barBackgroundImage: UIImage = UIImage()
    var barShadowImage: UIImage = UIImage()
    var isBarTranslucent: Bool = true
    var modalPresentationStyle: UIModalPresentationStyle = .fullScreen

    func viewController() -> UINavigationController {
        var navigation: UINavigationController!

        if let root = root { navigation = UINavigationController(rootViewController: root)
        } else { navigation = UINavigationController() }

        navigation.interactivePopGestureRecognizer?.isEnabled = isInteractivePopGesture
        navigation.navigationBar.setBackgroundImage(barBackgroundImage, for: .default)
        navigation.navigationBar.shadowImage = barShadowImage
        navigation.navigationBar.isTranslucent = isBarTranslucent
        navigation.modalPresentationStyle = modalPresentationStyle

        return navigation
    }
}
