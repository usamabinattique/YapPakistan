//
//  MenuSeparatorTableViewCell.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxTheme

class MenuSeparatorTableViewCell: RxUITableViewCell {

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "DAE0F0")! //greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: MenuUserTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? MenuUserTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
    }

}

// MARK: View setup

private extension MenuSeparatorTableViewCell {
    func setupViews() {
        contentView.addSubview(separator)
    }
    
    func setupConstraints() {
        separator
            .alignEdgesWithSuperview([.left, .right, .top], constants: [0, 0, 0])
            .alignEdgeWithSuperview(.bottom, constant: 13, priority: .defaultHigh)
            .height(constant: 1)
    }
}
