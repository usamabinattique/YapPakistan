//
//  YAPProgressHud+Rx.swift
//  YAPPakistan
//
//  Created by Sarmad on 16/09/2021.
//

import YAPComponents
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var loader:Binder<Bool> {
        return Binder<Bool>.init(self.base) { _, value in
            if value { YAPProgressHud.showProgressHud() }
            else { YAPProgressHud.hideProgressHud() }
        }
    }
}
