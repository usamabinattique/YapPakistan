//
//  RxPasscodeKeyboard.swift
//  YAPPakistan
//
//  Created by Sarmad on 06/09/2021.
//

import RxSwift
import RxCocoa
import YAPComponents

class RxPasscodeKeyboard:PasscodeKeyboard {
    var clearTextSubject = PublishSubject<Void>()
}

extension Reactive where Base: RxPasscodeKeyboard {
    
    var output: Observable<String> {
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
        let clear = base.clearTextSubject.map { _ in String(UnicodeScalar(0)) }
        let merged = Observable.merge(zero, one, two, three, four, five, six, seven, eight, nine).unwrap()
        return Observable.merge(merged, backspace, clear)
    }
    
    var biometricsButtonTap: ControlEvent<Void> {
        return base.biomatryButton.rx.tap
    }
    
    var biometryEnable: Binder<Bool> {
        return base.biomatryButton.rx.isEnabled
    }
    
    var clearTextObserver: AnyObserver<Void> {
        return base.clearTextSubject.asObserver()
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { keypad, isEnabled in
            [keypad.one, keypad.two, keypad.three, keypad.four, keypad.five, keypad.six, keypad.seven, keypad.eight, keypad.nine, keypad.zero, keypad.backButton]
                .forEach { $0.isEnabled = isEnabled }
        }
    }
}

