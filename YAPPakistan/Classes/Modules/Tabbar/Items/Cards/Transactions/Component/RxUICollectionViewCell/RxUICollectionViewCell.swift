//
//  RxUICollectionViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 26/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift

open class RxUICollectionViewCell: UICollectionViewCell, ReusableView {
    
    private(set) var disposeBag = DisposeBag()
    var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(with viewModel: Any) {
        fatalError("Configure with viewModel must be implemented.")
    }
}
