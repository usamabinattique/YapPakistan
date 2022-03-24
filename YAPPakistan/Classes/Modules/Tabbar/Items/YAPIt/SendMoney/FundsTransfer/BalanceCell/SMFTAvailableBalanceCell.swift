//
//  SMFTAvailableBalanceCell.swift
//  YAP
//
//  Created by Zain on 17/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class SMFTAvailableBalanceCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var balance = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    // MARK: Properties
    
    private var viewModel: SMFTAvailableBalanceCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private var topConstraint: NSLayoutConstraint!
    
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
        guard let `viewModel` = viewModel as? SMFTAvailableBalanceCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        self.bindViews()
    }
}

// MARK: View setup

private extension SMFTAvailableBalanceCell {
    func setupViews() {
        contentView.addSubview(balance)
    }
    
    func setupConstraints() {
        balance
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .bottom], constants: [25, 25])
        
        topConstraint = balance.topAnchor.constraint(equalTo: contentView.topAnchor)
        topConstraint.isActive = true
    }
}

// MARK: Binding

private extension SMFTAvailableBalanceCell {
    func bindViews() {
        viewModel.outputs.balance.bind(to: balance.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.addPadding
            .subscribe(onNext: { [weak self] in self?.topConstraint.constant = $0 ? 20 : 0 })
            .disposed(by: disposeBag)
    }
}
