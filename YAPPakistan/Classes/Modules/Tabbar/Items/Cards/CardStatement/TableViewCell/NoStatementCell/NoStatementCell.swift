//
//  PaymentCardNoStatementCell.swift
//  YAP
//
//  Created by Zain on 17/01/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import RxTheme

class NoStatementCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var label = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "Nothing to report yet")
    
    // MARK: Properties
    
    private var viewModel: NoStatementCellViewModelType!
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
        guard let viewModel = viewModel as? NoStatementCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
    }
}

// MARK: View setup

private extension NoStatementCell {
    func setupViews() {
        contentView.addSubview(label)
    }
    
    func setupConstraints() {
        label
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 40, 25, 0])
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: label.rx.textColor)
            .disposed(by: disposeBag)
    }
}
