//
//  PasscodeDottedView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

extension Reactive where Base: PasscodeDottedView {
    var characters: Binder<Int> {
        return Binder(base) { passCodeView, count in
            passCodeView.characters(total: count)
        }
    }
}
