//
//  Observable+Logging.swift
//  iOSApp
//
//  Created by Abbas on 06/06/2021.
//

import Foundation
import RxSwift

extension Observable {
    func logError(prefix: String = "Error: ") -> Observable<Element> {
        return self.do(onError: { print("\(prefix)\($0)") })
    }

    func logServerError(message: String) -> Observable<Element> {
        return self.do(onError: { error in
            print("\(message)")
            print("Error: \(error.localizedDescription). \n")
        })
    }

    func logNext() -> Observable<Element> {
        return self.do(onNext: { print("\($0)") })
    }
}
