//
//  TransactionDetailImproveAttributesCell.swift
//  Cards
//
//  Created by Muhammad Hassan on 26/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import RxTheme

public class TransactionDetailImproveAttributesCell: RxUITableViewCell {
    
    // MARK: - Views
    private lazy var titleLabel = UIFactory.makeLabel(font: .large) //UILabelFactory.createUILabel(with: .primary, textStyle: .large)
    
    // MARK: - Properties
    private var viewModel: TransactionDetailImproveAttributesCellViewModel!
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
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TransactionDetailImproveAttributesCellViewModel else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionDetailImproveAttributesCellViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
//        setupResources()
    }
    
    func setupViews() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        titleLabel.centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.top, .bottom], constant: 20)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [titleLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func bindViews() {
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
    }
}
