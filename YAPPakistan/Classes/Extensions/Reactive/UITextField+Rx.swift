//
//  UITextField+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
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
