//
//  TransactionDetailCategoryCell.swift
//  Cards
//
//  Created by Muhammad Hassan on 16/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import RxTheme

public class TransactionDetailCategoryCell: RxUITableViewCell {
    
    // MARK: - Views
    private lazy var categoryLabel = UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small)
    private lazy var subtitleLabel = UIFactory.makeLabel(font: .micro) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro)
    private lazy var iconImageView = UIImageViewFactory.createImageView()
    private lazy var separatorView: UIView = {
        let view = UIView()
       // view.backgroundColor =  //UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.height(constant: 1)
        return view
    }()
    private lazy var labelsStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 5, arrangedSubviews: [categoryLabel, subtitleLabel])
    private lazy var labelsAndSeparatorStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 20, arrangedSubviews: [labelsStackView, separatorView])
    private lazy var contentStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .top, distribution: .fill, spacing: 16, arrangedSubviews: [iconImageView, labelsAndSeparatorStackView])
    
    // MARK: - Properties
    private var viewModel: TransactionDetailCategoryCellViewModel!
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
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        iconImageView.roundView()
    }
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TransactionDetailCategoryCellViewModel else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionDetailCategoryCellViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
//        setupTheme()
    }
}

private extension TransactionDetailCategoryCell {
    
    func setupViews() {
        contentView.addSubview(contentStackView)
        iconImageView.image = UIImage(named: "small", in: .yapPakistan, compatibleWith: nil)
    }
    
    func setupConstraints() {
        iconImageView.height(constant: 42).width(constant: 42)
        contentStackView.alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [20, 0, 20, 20])
    }
    
    func bindViews() {
        viewModel.category.bind(to: categoryLabel.rx.text).disposed(by: disposeBag)
        viewModel.subtitle.bind(to: subtitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.icon.bind(to: iconImageView.rx.loadImage()).disposed(by: disposeBag)
    }
}
