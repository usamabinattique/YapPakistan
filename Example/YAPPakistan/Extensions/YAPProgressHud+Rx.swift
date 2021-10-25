//
//  YAPProgressHud+Rx.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
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
