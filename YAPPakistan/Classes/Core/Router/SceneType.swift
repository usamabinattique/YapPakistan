//
//  ViewType.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public protocol SceneType:AnyObject {
    init(_ scene:UIViewController)
    func getCurrentScene() -> UIViewController?
}
