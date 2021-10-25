//
//  UIView+Rx.swift
//  YAPPakistan_Example
//
//  Created by Tayyab on 18/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import RxSwift
import UIKit

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
