//
//  AppSearchBar+Rx.swift
//  YAPPakistan
//
//  Created by Umair  on 18/01/2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive

public extension Reactive where Base: AppSearchBar {
    var text: ControlProperty<String?> { return self.base.textField.rx.text }
    var cancelTap: ControlEvent<Void> { return self.base.cancelButton.rx.tap }
}
