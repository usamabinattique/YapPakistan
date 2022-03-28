//
//  SMFTChargesCell.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxTheme

class SMFTChargesCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var charges = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    // MARK: Properties
    
    var viewModel: SMFTChargesCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTChargesCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
    
}

// MARK: View setup

private extension SMFTChargesCell {
    
    func setupViews() {
        contentView.addSubview(charges)
    }
    
    func setupConstraints() {
        
        charges
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 20, 25, 20])
    }
}

// MARK: Binding

private extension SMFTChargesCell {
    func bindViews() {
        viewModel.outputs.charges.bind(to: charges.rx.attributedText).disposed(by: disposeBag)
    }
}
