//
//  PK+Coordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 22/06/2022.
//

import Foundation
import YAPCore
import RxSwift

extension Coordinator {
    
    public func navigate<ResultType>(to coordinator: Coordinator<ResultType>) -> Observable<ResultType> {
        
        let manager = AppRestrictionManager.shared
        if let _ = manager.account {
            if manager.blockFeatures.contains(coordinator.feature) {
                if manager.restrictions.count > 0 {
                    manager.restrictions.first!.showFeatureBlockAlert()
                    return Observable<ResultType>.create { (observer) -> Disposable in
                        observer.onCompleted()
                        return Disposables.create()
                    }
                } else {
                    return Observable<ResultType>.create { (observer) -> Disposable in
                        observer.onCompleted()
                        return Disposables.create()
                    }

                }
            }
        }
        
        return self.coordinate(to: coordinator)
        
    }
    
}
