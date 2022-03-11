//
//  DenominationAmountCollectionViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 05/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class DenominationAmountCollectionViewCell: RxUICollectionViewCell {
    
    private lazy var amountLabel: UILabel = UIFactory.makeLabel(font: .micro) //.primary, textStyle: .micro)
    private var viewModel: DenominationAmountViewModelType?
    private var themeService: ThemeService<AppTheme>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupViews()
//        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? DenominationAmountViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        setupViews()
        setupConstraints()
        bind(viewModel: viewModel)
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
}

extension DenominationAmountCollectionViewCell {
    func setupViews() {
        contentView.backgroundColor =  UIColor(self.themeService.attrs.primary).withAlphaComponent(0.15)//UIColor.primary.withAlphaComponent(0.15)
        contentView.addSubview(amountLabel)
    }
    
    func setupConstraints() {
        amountLabel
            .centerInSuperView()
    }
    
    func bind(viewModel: DenominationAmountViewModelType) {
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
    }
}
