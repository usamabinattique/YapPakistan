//
//  ResultType.swift
//  YAPMVVMC
//
//  Created by Sarmad on 27/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

//MARK:- Generic result type
public enum ResultType<T> {
    case success(T)
    case cancel
    
    public var isCancel: Bool {
        if case ResultType.cancel = self {
            return true
        }
        return false
    }
    
    public var isSuccess: T? {
        guard !isCancel else { return nil }
        if case let ResultType.success(value) = self {
            return value
        }
        return nil
    }

}
