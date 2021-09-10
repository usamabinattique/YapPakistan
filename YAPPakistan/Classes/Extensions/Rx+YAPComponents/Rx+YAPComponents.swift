//
//  Rx+YAPComponents.swift
//  YAPComponents
//
//  Created by Sarmad on 06/09/2021.
//

import YAPComponents
import RxCocoa
import RxSwift

/*
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
*/
