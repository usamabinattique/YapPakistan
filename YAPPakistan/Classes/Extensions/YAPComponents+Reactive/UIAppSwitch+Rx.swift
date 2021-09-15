//
//  UIAppSwitch+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
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
