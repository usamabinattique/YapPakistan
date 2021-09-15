//
//  UITableView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift

extension Reactive where Base: UITableView {
    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}
