//
//  Localization+Rx.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/09/2021.
//

import RxSwift
import RxCocoa

extension UIViewController {
    func localizationService() {
        let languageChanged = BehaviorRelay<Void>(value: ())
        
        NotificationCenter.default
            .rx.notification(Notification.Name.AVPlayerItemDidPlayToEndTime)
            .subscribe { [weak self] (event) in
                languageChanged.accept(())
            }.disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base: NotificationCenter {
    public func notification(_ name: Notification.Name?, object: AnyObject? = nil) -> Observable<Notification> {
        return Observable.create { [weak object] observer in
            let nsObserver = self.base.addObserver(forName: name, object: object, queue: nil) { notification in
                observer.on(.next(notification))
            }
            
            return Disposables.create {
                self.base.removeObserver(nsObserver)
            }
        }
    }
}


