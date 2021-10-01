//
//  Bundle+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 08/09/2021.
//

import Foundation

public extension Bundle {
    private class YAPPakistanBundle {  }

    static var yapPakistan: Bundle {
        let mainBundle = Bundle(for: YAPPakistanBundle.self)
        let bundlePath = mainBundle.path(forResource: "YAPPakistan", ofType: "bundle")
        let libBundle = Bundle(path: bundlePath ?? "")

        return libBundle ?? mainBundle
    }
}
