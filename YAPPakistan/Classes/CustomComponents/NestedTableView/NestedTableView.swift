//
//  NestedTableView.swift
//  YAPPakistan
//
//  Created by Umair  on 15/05/2022.
//

import Foundation

///If you need to implement a nested tableView
///use this class for nested tableView declared in Cell class
///and make sure cell layout is configured as automaticDimension

class NestedTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet{
            self.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
