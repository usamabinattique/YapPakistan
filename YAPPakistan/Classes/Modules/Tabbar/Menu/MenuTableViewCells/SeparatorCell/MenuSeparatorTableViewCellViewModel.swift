//
//  MenuSeparatorTableViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents

protocol MenuSeparatorTableViewCellViewModelType {}

class MenuSeparatorTableViewCellViewModel: MenuSeparatorTableViewCellViewModelType, ReusableTableViewCellViewModelType {
    
    var reusableIdentifier: String { return MenuSeparatorTableViewCell.defaultIdentifier }
}
