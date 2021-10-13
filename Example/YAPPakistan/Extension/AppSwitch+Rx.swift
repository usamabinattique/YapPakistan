//
//  AppSwitch+Rx.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import YAPComponents

extension Reactive where Base: AppSwitch {
    /// Reactive wrapper for `isOn` property.
    var isOn: ControlProperty<Bool> {
        return value
    }

    /// Reactive wrapper for `isOn` property.
    ///
    /// underlying observable sequence won't complete when nothing holds a strong reference
    /// to `UIAppSwitch`.
    var value: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { appSwitch in
            appSwitch.isOn
        }) { appSwitch, value in
            appSwitch.isOn = value
        }
    }
}
