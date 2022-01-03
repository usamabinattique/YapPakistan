//
//  YAPCheckBox+Rx.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import RxCocoa
import RxSwift
import YAPComponents

// MARK: Reactive

public extension Reactive where Base: YAPCheckBox {
    var checked: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { checkBox in
            return checkBox.checked
        }) { (checkBox, checked) in
            checkBox.checked = checked
        }
    }
}
