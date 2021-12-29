//
//  RxUITableViewCell.swift
//  YAPKit
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import SwipeCellKit

protocol ConfigurableView {
    func configure(with viewModel: Any)
}

protocol ConfigurableTableViewCell: ConfigurableView {
    func setIndexPath(_ indexPath: IndexPath)
}

open class RxUITableViewCell: UITableViewCell, ReusableView, ConfigurableTableViewCell {
    private(set) var disposeBag = DisposeBag()
    var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(with viewModel: Any) {
        fatalError("Configure with viewModel must be implemented.")
    }
    
    func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}

open class RxSwipeTableViewCell: SwipeTableViewCell, ReusableView, ConfigurableTableViewCell {
    private(set) var disposeBag = DisposeBag()
    var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(with viewModel: Any) {
        fatalError("Configure with viewModel must be implemented.")
    }
    
    func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}
