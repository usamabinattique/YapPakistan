//
//  Rx+YAPComponents.swift
//  YAPComponents
//
//  Created by Sarmad on 06/09/2021.
//

import YAPComponents
import RxCocoa
import RxSwift

// MARK: Reactive AppRoundedTextField
public extension Reactive where Base: AppRoundedTextField {
    
    var iconTap: ControlEvent<Void> {
        return self.base.iconImage.rx.tap
    }
    
    var validation: Binder<AppRoundedTextFieldValidation> {
        return Binder(self.base) { roundedTextField, validation -> Void in
            roundedTextField.setValidation(validation)
        }
    }
    
    var invalidInputImage: Binder<UIImage?> {
        return Binder(self.base) { roundedTextField, invalidImage -> Void in
            roundedTextField.invalidInputImage = invalidImage
        }
    }
    
    var icon: Binder<UIImage?> {
        return Binder(self.base) { roundedTextField, icon -> Void in
            roundedTextField.icon = icon
        }
    }
    
    var borderColor: Binder<UIColor> {
        return Binder(self.base) { _, color -> Void in
            self.base.layer.borderColor = color.cgColor
        }
    }
    
    var displaysIcon: Binder<Bool> {
        return Binder(self.base) { roundedTextField, displaysIcon -> Void in
            roundedTextField.displaysIcon = displaysIcon
        }
    }
    
    var errorText: Binder<String?> {
        return self.base.errorLabel.rx.text
    }
}

// MARK: Reactive UICircularButton
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

// MARK: Reactive YAPAlert
public extension Reactive where Base: YAPAlert {
    var tap: ControlEvent<Void> {
        return self.base.actionButton.rx.tap
    }
}

// MARK: Reactive UIAppSwitch
extension Reactive where Base: UIAppSwitch {
    /// Reactive wrapper for `isOn` property.
    public var isOn: ControlProperty<Bool> {
        return value
    }

    /// Reactive wrapper for `isOn` property.
    ///
    /// underlying observable sequence won't complete when nothing holds a strong reference
    /// to `UIAppSwitch`.
    public var value: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { appSwitch in
            appSwitch.isOn
        }) { appSwitch, value in
            appSwitch.isOn = value
        }
    }
}

// MARK: Reactive BorderedLabel
extension Reactive where Base: BorderedLabel {
    var highlight: Binder<Bool> {
        return Binder(self.base) { label, highlight -> Void in
            label.highlight = highlight
        }
    }
}
// MARK: Reactive CodeVerificationTextField
public extension Reactive where Base: CodeVerificationTextField {
    var clear: Binder<Void> {
        return Binder(self.base) { textFiled, _ -> Void in
            ///will upate this latter
            textFiled.clearText()
        }
    }
}

// MARK: Reactive PasscodeDottedView
extension Reactive where Base: PasscodeDottedView {
    public var characters: Binder<Int> {
        return Binder(base) { passCodeView, count in
            passCodeView.characters(total: count)
        }
    }
}


// MARK: Reactive OnBoardingProgressView
public extension Reactive where Base: OnBoardingProgressView {
    var progress: Binder<Float> {
        return Binder(self.base) { progressView, progress -> Void in
            progressView.setProgress(progress)
        }
    }
    
    var tapBack: ControlEvent<Void> {
        return self.base.backButton.rx.tap
    }
    
    var animateCompletion: Binder<Bool> {
        return Binder(self.base) { progressView, completion -> Void in
            completion ? progressView.animateCompletion() : progressView .undoAnimateCompletion()
        }
    }
    
    /*
    var disableBackButton: Binder<Bool> {
        return Binder(self.base) { progressView, isDisabled -> Void in
            isDisabled ? progressView.disableBackButton() : progressView.enableBackButton()
        }
    }
    
    var hideBackButton: Binder<Bool> {
        return Binder(self.base) { progressView, isHidden -> Void in
            isHidden ? progressView.hideBackButton() : progressView.showBackButton()
        }
    } */
    
    var tintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.tintColor = attr
        }
    }
    
    var trackTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.disabledColor = attr
        }
    }
}
