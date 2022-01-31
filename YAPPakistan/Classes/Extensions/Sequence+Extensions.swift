//
//  Sequence+Extensions.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 05/01/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation

public extension Sequence where Iterator.Element: Equatable {
    
    func unique() -> [Iterator.Element] {
        return reduce([], { collection, element in collection.contains(element) ? collection : collection + [element] })
    }
    
}

