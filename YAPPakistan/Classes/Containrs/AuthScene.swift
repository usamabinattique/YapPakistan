//
//  TestingRouter.swift
//  YAPMVVMC
//
//  Created by Sarmad on 29/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

final class AuthScene:Scene { }

extension AuthScene {
    static func splashScene() -> Self {
        return Self.init(UIViewController())
    }
    
    static func signupScene() -> Self {
        return Self.init(UIViewController())
    }
    
    static func loginScene() -> Self {
        return Self.init(UIViewController())
    }
}
