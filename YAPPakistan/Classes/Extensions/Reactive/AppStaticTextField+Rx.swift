//
//  AppStaticTextField+Rx.swift
//  YAPPakistan
//
//  Created by Umair  on 03/03/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

// MARK: - StaticAppTextField+Rx
extension Reactive where Base: StaticAppTextField {
    public var title: Binder<String?> {
        return Binder(self.base) { field, title in
            field.titleLabel.text = title
        }
    }

    public var text: Binder<String?> {
        return Binder(self.base) { field, text in
            field.textLabel.text = text
        }
    }

    public var editObserver: ControlEvent<Void> {
        return base.editButton.rx.tap
    }
}
