//
//  RxUITableViewCell.swift
//  YAPKit
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxTheme

public protocol ConfigurableView {
    func configure(with themeService: ThemeService<AppTheme>, viewModel: Any)
}

public protocol ConfigurableTableViewCell: ConfigurableView {
    func setIndexPath(_ indexPath: IndexPath)
}

open class RxUITableViewCell: UITableViewCell, ReusableView, ConfigurableTableViewCell {
    
    private(set) public var disposeBag = DisposeBag()
    public var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        fatalError("Configure with viewModel must be implemented.")
    }
    
    public func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}
