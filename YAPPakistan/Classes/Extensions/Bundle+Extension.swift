//
//  Bundle+Extension.swift
//  YAPComponents
//
//  Created by Sarmad on 07/09/2021.
//

import Foundation

private class YapResources {
    static var bundle:Bundle { return Bundle(for: Self.self) }
}

public extension Bundle {
    static var yapPakistan:Bundle { YapResources.bundle }
}
