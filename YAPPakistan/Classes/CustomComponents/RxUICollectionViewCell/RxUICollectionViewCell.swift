//
//  RxUICollectionViewCell.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import UIKit
import RxSwift
import RxTheme

open class RxUICollectionViewCell: UICollectionViewCell, ReusableView {
    
    private(set) public var disposeBag = DisposeBag()
    public var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(with viewModel: Any, theme : ThemeService<AppTheme>) {
        fatalError("Configure with viewModel must be implemented.")
    }
    
}
