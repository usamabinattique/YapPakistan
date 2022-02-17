//
//  UICollectionView+Rx.swift
//  YAPPakistan
//
//  Created by Yasir on 10/02/2022.
//

import YAPComponents
import RxCocoa
import RxSwift

extension UICollectionView {
    public func configureForPeekingDelegate(scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        self.decelerationRate = .fast
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isPagingEnabled = false
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = scrollDirection
    }
    
    public var currentPage: Int {
        set(value) {
            setCurrentPage(value, animated: true)
        }
        get {
            let offset = contentOffset.x
            let visibleIndexes = indexPathsForVisibleItems.map { $0.row }
            return visibleIndexes.count < 3 ? ((offset == 0 ? visibleIndexes.min() : visibleIndexes.max()) ?? 0) : visibleIndexes.reduce(0) { $0 + $1 }/visibleIndexes.count
        }
    }
    
    public func setCurrentPage(_ page: Int, animated: Bool = true) {
        scrollToItem(at: IndexPath(row: page, section: 0), at: .centeredHorizontally, animated: animated)
    }
}

public extension UIScrollView {
    var currentSelectedPage: Int {
        let offset = contentOffset.x
        return Int(ceil(offset/bounds.width))
    }
}

public extension Reactive where Base: UICollectionView {
    var currentPage: Observable<Int> {
        return self.base.rx.didEndDecelerating.map { self.base.currentPage }
    }
}

public extension Reactive where Base: UIScrollView {
    var currentPage: Observable<Int> {
        return self.base.rx.didEndDecelerating.map { self.base.currentSelectedPage }
    }
}
