//
//  UITableView+Extension.swift
//  YAP
//
//  Created by Wajahat Hassan on 23/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

extension UITableView {
    var startLoadingOffset: CGFloat {
        return 20.0
    }
    
    func isNearTheBottomEdge(_ contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height +
            startLoadingOffset > tableView.contentSize.height
    }
    
    var isNearTheTopEdge: Bool {
        return contentOffset.y <= 10
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension Reactive where Base: UITableView {
    var loadNextPageTrigger: Observable<Void> {
        return base.rx.contentOffset
            .flatMap { [weak base] (_) -> Observable<Void> in
                guard let `base` = base else { return Observable.empty() }
                return base.isNearBottomEdge(edgeOffset: 20) ? Observable.just(Void()) : Observable.empty()
        }.debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
    }
    
    var visibleIndexPath: Observable<IndexPath?> {
        
        return base.rx.didScroll.map { [weak base] _ in
            guard let `base` = base,
            base.isTracking || base.isDragging || base.isDecelerating else { return nil }
            return base.indexPathsForVisibleRows.flatMap { indexPaths -> IndexPath? in
                //if base.isNearTheTopEdge {
                    return indexPaths.first
//                } else if base.isNearTheBottomEdge(base.contentOffset, base) {
//                    return indexPaths.last
//                } else {
//                    return indexPaths.first
//                }
            }
        }

//        return Observable<IndexPath?>.create { [weak base] observer in
//            guard let `base` = base else { return Disposables.create() }
//            base.indexPathsForVisibleRows.map { indexPaths in
//                if base.isNearTheTopEdge {
//                    observer.onNext(indexPaths.first)
//                } else if base.isNearTheBottomEdge(base.contentOffset, base) {
//                    observer.onNext(indexPaths.last)
//                } else {
//                    observer.onNext(indexPaths.first)
//                }
//            }
//            return Disposables.create()
//        }
    }
}
