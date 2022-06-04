//
//  YAPActionSheetBigIconTableViewCell.swift
//  YAPKit
//
//  Created by Janbaz Ali on 27/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import UIKit

class YAPActionSheetBigIconTableViewCell: YAPActionSheetTableViewCell {

    //MARK: - Init
    override func commonInit() {
        selectionStyle = .none
        self.bigIcon = true
        self.setupViews()
        self.setupConstraints()
    }
}
