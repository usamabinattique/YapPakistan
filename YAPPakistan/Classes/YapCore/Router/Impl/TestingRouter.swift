//
//  TestingRouter.swift
//  YAPMVVMC
//
//  Created by Sarmad on 29/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit


/*
public protocol AuthSceneTypes {
    static func splashScene() -> Self   //SceneType
    static func signupScene() -> Self   //SceneType
    static func loginScene()  -> Self   //SceneType
} */

final class AuthScene:Scene { }
final class TransuctionScene:Scene { }

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

extension TransuctionScene {
    static func cashWithDraw() -> Self {
        return Self.init(UIViewController())
    }
    
    static func depositCash() -> Self {
        return Self.init(UIViewController())
    }
    
    static func sendCash() -> Self {
        return Self.init(UIViewController())
    }
}


class Test {
    func Test() {
        let routerA:Router = Router<AuthScene>()
        routerA.show(scene: .loginScene(), sender: nil, transition: .root(in: nil, animated: true))
        
        let routerT:Router = Router<TransuctionScene>()
        routerT.show(scene: .cashWithDraw(), sender: nil, transition: .root(in: nil, animated: true))
    }
}

class TestVc:Navigatable {
    var navigator:Router<AuthScene>?
}
