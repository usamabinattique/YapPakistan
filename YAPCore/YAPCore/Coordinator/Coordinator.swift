//
//  Coordinator.swift
//
//  Created by Arthur Myronenko on 6/29/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

import Foundation
import RxSwift

/// Base abstract coordinator generic over the return type of the `start` method.
open class Coordinator<T>:NSObject, CoordinatorType {
    
    //typealias ResultType =
    typealias CoordinationResult = T
    
    //typealias ResultType = ResultType
    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.

    /// Unique identifier.
    private let identifier = UUID()

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators:[UUID: Any] = [:]
    
    deinit { debugPrint("==================\(Self.className)_Deinited=================") }

    //MARK: Confirmation of CoordinatorType
    public func coordinate<ResultType>(
        to coordinator: Coordinator<ResultType>
    ) -> Observable<ResultType> {
        return coordinator
            .start()
            .do(onNext: { [weak self] _ in
                self?.free(coordinator: coordinator)
            })
    }
    
    open func start(with option: DeepLinkOptionType?) -> Observable<T> {
        fatalError("Start method should be implemented.")
    }
}

//MARK: - Private Methods
fileprivate extension Coordinator {
    /// Stores coordinator to the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Child coordinator to store.
    func store<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    /// Release coordinator from the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Coordinator to release.
    func free<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
}
