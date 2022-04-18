//
//  DropDownButton.swift
//  YAPKit
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class DropDownButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setImage(UIImage(named: "icon_drop_down", in: .yapPakistan), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public var buttonState: DropDownButton.ButtonState = .down {
        didSet {
            UIView.animate(withDuration: 0.25) { [unowned self] in
                if self.buttonState == .down {
                    self.transform = CGAffineTransform.identity
                } else {
                    self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
                }
            }
        }
    }
}

public extension DropDownButton {
    enum ButtonState {
        case down
        case up
    }
}

public extension Reactive where Base: DropDownButton {
    var buttonState: Binder<DropDownButton.ButtonState> {
        return Binder(self.base) { button, state -> Void in
            button.buttonState = state
        }
    }
}
