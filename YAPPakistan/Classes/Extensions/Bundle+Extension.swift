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
        Bundle(for: YAPPakistanBundle.self)
    }
}
