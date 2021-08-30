//
//  Scene.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
public class Scene: SceneType {
    
    private var currentScene: UIViewController?
    
    required public init(_ scene: UIViewController) {
        self.currentScene = scene
    }
    
    public func getCurrentScene() -> UIViewController? {
        return currentScene
    }
}
