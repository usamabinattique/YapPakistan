//
//  Localization+Rx.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/09/2021.
//

import RxSwift
import RxCocoa

extension UIViewController {
    var languageChanged:Observable<Void> {
        return NotificationCenter.default.rx.notification(NSLocale.currentLocaleDidChangeNotification).map { _ in () }.startWith(())
    }
}
