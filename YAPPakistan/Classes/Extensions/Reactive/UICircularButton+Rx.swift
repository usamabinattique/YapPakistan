//
//  UICircularButton+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

extension Reactive where Base: UICircularButton {
    public var themeColor: Binder<UIColor> {
        return Binder(base) { button, color in
            button.themeColor = color
        }
    }

    public var titleTap: Observable<String?> {
        return base.rx.tap.withLatestFrom(Observable.of(base.buttonTitle))
    }
}
