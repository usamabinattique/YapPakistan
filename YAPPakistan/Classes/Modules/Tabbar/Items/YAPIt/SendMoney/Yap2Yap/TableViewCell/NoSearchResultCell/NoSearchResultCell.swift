//
//  NoSearchResultCell.swift
//  YAP
//
//  Created by Zain on 10/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import RxTheme
import UIKit

open class NoSearchResultCell: RxUITableViewCell {
    // MARK: Views
    
    private lazy var title =  UIFactory.makeLabel(font: .large, alignment: .center, text: "No results") //.greyDark
    
    // MARK: Properties
    
    private var viewModel: NoSearchResultCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        setupConstraints()
    }
    
    // MARK: Configurations
    
    open override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? NoSearchResultCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        self.setupTheme()
        self.setupSubViews()
        self.setupBindings()
        self.setupConstraints()
    }
}

// MARK: View setup

extension NoSearchResultCell: ViewDesignable {
    
    public func setupBindings() {
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
    }
    
    public func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [title.rx.textColor])
    }
    
    public func setupSubViews() {
        contentView.addSubview(title)
    }
    
    public func setupConstraints() {
        title
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 65, 25, 15])
    }
    
}
