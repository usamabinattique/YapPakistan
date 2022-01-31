//
//  AppTextField+Rx.swift
//  YAPPakistan
//
//  Created by Yasir on 27/01/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

// MARK: - Reactive

public extension Reactive where Base: AppTextField {
    
    var validationState: Binder<AppTextField.ValidationState> {
        return Binder(self.base) { textField, validation -> Void in
            textField.validationState = validation
        }
    }
    
    var icon: Binder<UIImage?> {
        return Binder(self.base) { textField, iconImage -> Void in
            textField.iconImage = iconImage
        }
    }
    
    var errorText: Binder<String?> {
        return self.base.error.rx.text
    }
    
    var titleText: Binder<String?> {
        return self.base.title.rx.text
    }
    
    var animatesTitleOnEditingBegin: Binder<Bool> {
        return Binder(self.base) { textField, animates -> Void in
            textField.animatesTitleOnEditingBegin = animates
        }
    }
}
