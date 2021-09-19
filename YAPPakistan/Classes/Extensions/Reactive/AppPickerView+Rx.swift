//
//  RxAppPickerView.swift
//  AppPickerView+Rx
//
//  Created by Sarmad on 06/09/2021.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

// MARK: Reactive

extension Reactive where Base: AppPickerView {
    var itemSelected: ControlEvent<(row: Int, component: Int)> {
        return base.pickerView.rx.itemSelected
    }

    var done: Observable<[(row: Int, component: Int)]> {
        return base.toolbaar.doneButton.rx.tap.map{ base.getSelectedIndexes() }
    }

    var cancel: Observable <Void> {
        return base.toolbaar.cancelButton.rx.tap.asObservable()
    }

    func itemTitles<S: Sequence, O: ObservableType>
        (_ source: O)
        -> (_ titleForRow: @escaping (Int, S.Iterator.Element) -> String?)
        -> Disposable where O.Element == S {
            return base.pickerView.rx.itemTitles(source)
    }

    func itemAttributedTitles<S: Sequence, O: ObservableType>
        (_ source: O)
        -> (_ attributedTitleForRow: @escaping (Int, S.Iterator.Element) -> NSAttributedString?)
        -> Disposable where O.Element == S {
            return base.pickerView.rx.itemAttributedTitles(source)
    }
}
