//
//  NavigatorType.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

//MARK: Protocol Router Type

protocol RouterType {
    associatedtype T:SceneType
    func pop(sender: UIViewController?)
    func pop(sender: UIViewController?, toRoot: Bool)
    func dismiss(sender: UIViewController?)
    func show(scene: T,
              sender: UIViewController?)
    func show(scene: T,
              sender: UIViewController?,
              transition: Transition)
}

extension RouterType {
    func pop(sender: UIViewController?){
        self.pop(sender: sender, toRoot: false)
    }
    func show(scene: T,
                 sender: UIViewController?) {
        show(scene: scene,
                  sender: sender,
                  transition: .navigation(type: .push(direction: .right)))
    }
}
