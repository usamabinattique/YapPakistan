//
//  BorderedLabel+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

extension Reactive where Base: BorderedLabel {
    var highlight: Binder<Bool> {
        return Binder(self.base) { label, highlight -> Void in
            label.highlight = highlight
        }
    }
}
