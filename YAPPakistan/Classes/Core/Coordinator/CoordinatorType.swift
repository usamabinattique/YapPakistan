//
//  CoordinatorType.swift
//  YapPakistanApp
//
//  Created by Sarmad on 23/08/2021.
//

import Foundation
import RxSwift

public protocol CoordinatorType {
    
    associatedtype ResultType
    
    /// Starts job of the coordinator.
    /// - Returns: Result of coordinator job.
    func start() -> Observable<ResultType>
    
    /// Starts job of the coordinator.
    /// - Parameter option: Deep linking optios
    /// - Returns: Result of coordinator job.
    func start(with option: DeepLinkOptionType?) -> Observable<ResultType>
    
    /// 1. Stores coordinator in a dictionary of child coordinators.
    /// 2. Calls method `start()` on that coordinator.
    /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    func coordinate(to coordinator: Self) -> Observable<ResultType>
}

public extension CoordinatorType {
    func start() -> Observable<ResultType> {
        start(with: nil)
    }
}
