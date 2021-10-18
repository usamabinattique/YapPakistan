//
//  UITextField+Rx.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }

    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

extension Reactive where Base: UITextField {
    var isFirstResponder: ControlProperty<Bool> {
        return value
    }

    var value: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: [.editingDidBegin, .editingDidEnd]) { tf in
            tf.isFirstResponder
        } setter: { tf, value in
            if value { tf.becomeFirstResponder() }
            else { tf.resignFirstResponder() }
        }
    }
}
