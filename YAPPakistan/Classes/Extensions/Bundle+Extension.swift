//
//  Bundle+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 08/09/2021.
//

import Foundation

extension Bundle {
    private class YAPPakistanBundle {   }
    static var YAPPakistan: Bundle {
        Bundle(for: YAPPakistanBundle.self)
    }
}
