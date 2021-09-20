//
//  CoordinatorType.swift
//  YapPakistanApp
//
//  Created by Sarmad on 23/08/2021.
//

import Foundation
import RxSwift

public protocol CoordinatorType {
    
    associatedtype TType
    
    /// Starts job of the coordinator.
    /// - Returns: Result of coordinator job.
    func start() -> Observable<TType>
    
    /// Starts job of the coordinator.
    /// - Parameter option: Deep linking optios
    /// - Returns: Result of coordinator job.
    func start(with option: DeepLinkOptionType?) -> Observable<TType>
    
    /// 1. Stores coordinator in a dictionary of child coordinators.
    /// 2. Calls method `start()` on that coordinator.
    /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    func coordinate(to coordinator: Self) -> Observable<TType>
}

public extension CoordinatorType {
    func start() -> Observable<TType> {
        start(with: nil)
    }
}
