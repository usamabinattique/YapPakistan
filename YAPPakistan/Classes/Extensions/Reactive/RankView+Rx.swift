//
//  RankView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift

extension Reactive where Base: RankView {
    var digitColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.digitColor = attr
        }
    }

    var digitBackgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.digitBackgroundColor = attr
        }
    }
}
