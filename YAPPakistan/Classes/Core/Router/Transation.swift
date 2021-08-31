//
//  TransationType.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Hero

enum Transition {
    case root(in: UIWindow?, animated:Bool)
    case navigation(type: HeroDefaultAnimationType)
    case customModal(type: HeroDefaultAnimationType)
    case modal
    case detail
    case alert
    case custom
}
