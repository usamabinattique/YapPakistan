//
//  RxAppPageControl.swift
//  YAPComponents
//
//  Created by Sarmad on 06/09/2021.
//

import YAPComponents
import RxCocoa
import RxSwift

class RxAppPageControl: AppPageControl {

    fileprivate let selectedPageSubject = PublishSubject<Int>()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        selectedPageSubject.subscribe(onNext: { [unowned self] page in
            self.setPageSelected(UInt(page))
        }).disposed(by: disposeBag)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// MARK: Rx
extension Reactive where Base: RxAppPageControl {
    internal var selectedPage: AnyObserver<Int> {
        return self.base.selectedPageSubject.asObserver()
    }
}
