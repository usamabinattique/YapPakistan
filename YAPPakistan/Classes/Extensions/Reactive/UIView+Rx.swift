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
            _ = view.animateIsHidden(hidden)
        }
    }
}

/*
public extension Reactive where Base: UIView {
    var animate: Binder<ViewAnimationType> {
        return Binder(self.base) { view, animation -> Void in
            view.animate(withType: animation)
        }
    }
}
*/

/*
 public extension Reactive where Base: UIView {
     func showAlert(ofType type: YAPAlert.AlertType, from direction: YAPAlert.AlertDirection = .top, autoHide: Bool = true, autoHideDuration: TimeInterval = 5) -> Binder<String> {
         return Binder(self.base) { view, text -> Void in
             view.showAlert(type: type, text: text, from: direction, autoHide: autoHide, autoHideDuration: autoHideDuration)
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

 */
