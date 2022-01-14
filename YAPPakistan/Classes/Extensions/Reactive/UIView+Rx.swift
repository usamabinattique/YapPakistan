//
//  UIView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift

extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }

    var showActivity: Binder<Bool> {
        return Binder(self.base) { view, showActivity -> Void in
            showActivity ? view.showProgressActivity() : view.hideProgressActivity()
        }
    }

    var endEditting: Binder<Bool> {
        return Binder(base) { view, end in
            _ = view.endEditing(end)
        }
    }

    var animateIsHidden: Binder<Bool> {
        return Binder(base) { view, hidden in
            view.animateIsHidden(hidden)
        }
    }
}

extension Reactive where Base: UIView {
    /// Bindable sink for `isShimmerOn` property.
    public var isShimmerOn: Binder<Bool> {
        return Binder(self.base) { view, shimmering in
            view.isShimmerOn = shimmering
        }
    }
}
