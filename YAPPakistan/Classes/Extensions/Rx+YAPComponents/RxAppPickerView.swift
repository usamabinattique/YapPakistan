//
//  RxAppPickerView.swift
//  YAPComponents
//
//  Created by Sarmad on 06/09/2021.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

class RxAppPickerView: AppPickerView {
    fileprivate let doneSubject = PublishSubject<[(row: Int, component: Int)]>()
    fileprivate let cancelSubject = PublishSubject<Void>()

    @objc override func doneAction() {

        var indexes = [(row: Int, component: Int)]()
        for i in 0..<pickerView.numberOfComponents {
            indexes.append((row: pickerView.selectedRow(inComponent: i), component: i))
        }
        // doneSubject.onNext(indexes)
    }

    @objc override func cancelAction() {
        // cancelSubject.onNext(())
    }
}

// MARK: Reactive

extension Reactive where Base: RxAppPickerView {

    var itemSelected: ControlEvent<(row: Int, component: Int)> {
        return self.base.pickerView.rx.itemSelected
    }

    var done: Observable<[(row: Int, component: Int)]> {
        return self.base.doneSubject.asObservable()
    }

    var cancel: Observable <Void> {
        return self.base.cancelSubject.asObservable()
    }

    func itemTitles<S: Sequence, O: ObservableType>
        (_ source: O)
        -> (_ titleForRow: @escaping (Int, S.Iterator.Element) -> String?)
        -> Disposable where O.Element == S {
            return self.base.pickerView.rx.itemTitles(source)
    }

    func itemAttributedTitles<S: Sequence, O: ObservableType>
        (_ source: O)
        -> (_ attributedTitleForRow: @escaping (Int, S.Iterator.Element) -> NSAttributedString?)
        -> Disposable where O.Element == S {
            return self.base.pickerView.rx.itemAttributedTitles(source)
    }
}
