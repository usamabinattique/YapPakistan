//
//  YAPPakistan.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import YAPPakistan
import YAPCore

func yapPakistanMainContainer() -> YAPPakistanMainContainer {
     YAPPakistanMainContainer(configuration: YAPPakistanConfiguration(environment: "develop"))
}