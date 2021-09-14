//
//  Localization+Rxx.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/09/2021.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectiveC
import UIKit

fileprivate var languageChangedContext: UInt8 = 0

extension UIViewController {
    var languageChanged:Observable<Void> {
        get {
            NotificationCenter.default
                .rx.notification(Notification.Name.AVPlayerItemDidPlayToEndTime)
                .subscribe { [weak self] (event) in
                    self?.rx.languageChanged.accept(())
                }.disposed(by: rx.disposeBag)
            
            return rx.languageChanged.asObservable()
        }
    }
}

extension Reactive where Base: UIViewController {
    func synchronizedLanguageChanged<T>( _ action: () -> T) -> T {
        objc_sync_enter(self.base)
        let result = action()
        objc_sync_exit(self.base)
        return result
    }
}

public extension Reactive where Base: UIViewController {

    /// a unique BehaviorRelay<Void> that is related to the Reactive.Base instance only for Reference type
    var languageChanged: BehaviorRelay<Void> {
        get {
            return synchronizedLanguageChanged {
                if let disposeObject = objc_getAssociatedObject(base, &languageChangedContext) as? BehaviorRelay<Void> {
                    return disposeObject
                }
                let disposeObject = BehaviorRelay<Void>(value: ())
                objc_setAssociatedObject(base, &languageChangedContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        
        set {
            return synchronizedLanguageChanged {
                objc_setAssociatedObject(base, &languageChangedContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

