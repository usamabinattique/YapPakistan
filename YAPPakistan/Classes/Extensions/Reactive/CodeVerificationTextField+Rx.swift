//
//  CodeVerificationTextField+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

extension Reactive where Base: CodeVerificationTextField {
    var clear: Binder<Void> {
        return Binder(self.base) { textFiled, _ -> Void in
            /// will upate this latter
            textFiled.clearText()
        }
    }
}
