//
//  NoDataIndecationCell.swift
//  Cards
//
//  Created by Wajahat Hassan on 16/02/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import UIKit
import RxTheme
import YAPComponents

class AnalyticsEmptyDataCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var label: UILabel = UIFactory.makeLabel(font: .regular)
    
    // MARK: Properties
    private var viewModel: AnalyticsEmptyDataCellViewModel!
    private var theme: ThemeService<AppTheme>!
    
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
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        label.textColor = UIColor(theme.attrs.greyDark)
        guard let vm = viewModel as? AnalyticsEmptyDataCellViewModel else {return}
        self.viewModel = vm
        bindViews()
    }
}

// MARK: View setup

private extension AnalyticsEmptyDataCell {
    func setupViews() {
        contentView.addSubview(label)
    }
    
    func setupConstraints() {
        label
            .alignEdgeWithSuperview(.top, constant: 40)
            .centerInSuperView()
    }
}

// MARK: Binding

private extension AnalyticsEmptyDataCell {
    func bindViews() {
        viewModel.noData.bind(to: label.rx.text).disposed(by: disposeBag)
    }
}
