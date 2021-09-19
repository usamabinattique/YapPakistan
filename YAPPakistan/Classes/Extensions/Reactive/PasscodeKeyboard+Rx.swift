//
//  PasscodeKeyboard+Rx.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/09/2021.
//

import RxSwift
import RxCocoa
import YAPComponents

extension Reactive where Base: PasscodeKeyboard {
    
    var keyTapped: Observable<String> {
        let zero = base.zero.rx.titleTap
        let one = base.one.rx.titleTap
        let two = base.two.rx.titleTap
        let three = base.three.rx.titleTap
        let four = base.four.rx.titleTap
        let five = base.five.rx.titleTap
        let six = base.six.rx.titleTap
        let seven = base.seven.rx.titleTap
        let eight = base.eight.rx.titleTap
        let nine = base.nine.rx.titleTap
        let backspace = base.backButton.rx.tap.map { _ in String(UnicodeScalar(8)) }
        let merged = Observable.merge(zero, one, two, three, four, five, six, seven, eight, nine).unwrap()
        return Observable.merge(merged, backspace) //, clear)
    }
    
    var themeColor: Binder<UIColor> {
        return Binder(self.base) { keyboard, thColor -> Void in
            keyboard.themeColor = thColor
        }
    }
}



