//
//  AppPageControl.swift
//  YAPComponents
//
//  Created by Sarmad on 06/09/2021.
//

import YAPComponents
import RxCocoa
import RxSwift

// MARK: Rx
extension Reactive where Base: AppPageControl {
    var selectedPage:Binder<Int> {
        Binder(self.base) { pageControl, pageNumber in
            pageControl.setPageSelected(UInt(pageNumber))
        }
    }
}
