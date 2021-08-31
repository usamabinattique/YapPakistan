//
//  Reatchability.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import Foundation
import RxSwift
import Alamofire

// Completes when the app gets online
func connectedToInternet() -> Observable<Bool> {
    return ReachabilityManager.shared.reach
}

private class ReachabilityManager: NSObject {

    static let shared = ReachabilityManager()

    fileprivate let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    var reach: Observable<Bool> {
        return reachSubject.asObservable()
    }

    override init() {
        super.init()

        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { (status) in
            switch status {
            case .reachable:
                self.reachSubject.onNext(true)
            case .notReachable, .unknown:
                self.reachSubject.onNext(false)
            }
        })
    }
}

