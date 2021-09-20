//
//  OnBoardingProgressView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 10/09/2021.
//

import Foundation
import RxCocoa
import RxSwift
import YAPComponents

extension Reactive where Base: OnBoardingProgressView {
    var progress: Binder<Float> {
        return Binder(self.base) { progressView, progress -> Void in
            progressView.setProgress(progress)
        }
    }

    var tapBack: ControlEvent<Void> {
        return self.base.backButton.rx.tap
    }

    var animateCompletion: Binder<Bool> {
        return Binder(self.base) { progressView, completion -> Void in
            completion ? progressView.animateCompletion() : progressView.undoAnimateCompletion()
        }
    }

    var tintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.tintColor = attr
        }
    }

    var trackTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.disabledColor = attr
        }
    }
}
