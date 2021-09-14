//
//  YAPAlert+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxCocoa
import RxSwift
import YAPComponents

extension Reactive where Base: YAPAlert {
    var tap: ControlEvent<Void> {
        return self.base.actionButton.rx.tap
    }
}
