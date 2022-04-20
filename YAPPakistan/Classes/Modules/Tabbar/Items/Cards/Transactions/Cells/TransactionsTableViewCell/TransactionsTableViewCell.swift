//
//  TransactionsTableViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import YAPComponents
import RxTheme

class TransactionsTableViewCell: RxUITableViewCell {
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        // view.backgroundColor = UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var parentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var transactionMerchantIconImageView: UIImageView = {
        let imageView = UIImageView()
        /// imageView.tintColor = .primary
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // tintColor: .white
    private lazy var transactionTypeIcon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var innerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var innerStackViewTwo: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var transactionTitle: UILabel = UIFactory.makeLabel(/*with: .primaryDark, */ font: .small)
    private lazy var internationalTransactionAmount: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .small)
    private lazy var transactionTimeCategory: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .small, numberOfLines: 2, lineBreakMode: .byWordWrapping)
    private lazy var transactionAmount: UILabel = UIFactory.makeLabel(/* with: .secondaryGreen, */ font: .small, alignment: .right)
    private lazy var currency: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .small, alignment: .right)
    
    private lazy var spacer:  UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var noteLabel: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .micro)
    
    private lazy var transactionStatusLabel: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .micro)
    
    var viewModel: TransactionsTableViewCellViewModelType!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionsTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconContainerView.removeGradientBackground()
        iconContainerView.backgroundColor = nil
    }
}

// MARK: SetupViews
private extension TransactionsTableViewCell {
    
    func setupViews() {
        contentView.backgroundColor = .white
        innerStackView.addArrangedSubview(transactionTitle)
        innerStackView.addArrangedSubview(transactionTimeCategory)
        innerStackView.addArrangedSubview(internationalTransactionAmount)
        innerStackView.addArrangedSubview(noteLabel)
        innerStackView.addArrangedSubview(transactionStatusLabel)
        innerStackViewTwo.addArrangedSubview(transactionAmount)
        innerStackViewTwo.addArrangedSubview(currency)
        innerStackViewTwo.addArrangedSubview(spacer)
        parentStackView.addArrangedSubview(innerStackView)
        parentStackView.addArrangedSubview(innerStackViewTwo)
        
        contentView.addSubview(iconContainerView)
        contentView.addSubview(parentStackView)
        contentView.addSubview(separatorView)
        contentView.addSubview(transactionTypeIcon)
        
        iconContainerView.addSubview(transactionMerchantIconImageView)
        
        iconContainerView.layer.cornerRadius = 22.5
        iconContainerView.clipsToBounds = true
        
        transactionTypeIcon.layer.cornerRadius = 8.5
        transactionTypeIcon.clipsToBounds = true
        
    }
    
    func setupConstraints() {
        
        transactionAmount.setContentCompressionResistancePriority(.required, for: .horizontal)
        currency.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        transactionAmount.setContentHuggingPriority(.required, for: .vertical)
        currency.setContentHuggingPriority(.required, for: .vertical)
        
        transactionAmount
            .height(YAPLayoutConstantModifier.equalTo, constant: 40, priority: .defaultLow)
        
        iconContainerView
            .alignEdgeWithSuperview(.left, constant: 25)
            .alignEdgeWithSuperview(.top, constant: 12)
            .width(constant: 45)
            .height(constant: 45)
        
        transactionMerchantIconImageView
            .alignAllEdgesWithSuperview()
        
        transactionTypeIcon
            .alignEdges([.right, .bottom], withView: iconContainerView, constants: [-3, -2])
            .width(constant: 17)
            .height(constant: 17)
        
        parentStackView
            .alignEdgeWithSuperview(.top, constant: 12)
            .alignEdgeWithSuperview(.right, constant: 25)
            .toRightOf(iconContainerView, constant: 25)
            .alignEdgeWithSuperview(.bottom, constant: 12)
        
        innerStackViewTwo.arrangedSubviews.forEach { $0.setContentHuggingPriority(.defaultHigh, for: .horizontal) }
        
        separatorView
            .alignEdges([.left, .right], withView: parentStackView)
            .alignEdgeWithSuperview(.bottom)
            .height(constant: 1)
    }
}

// MARK: Binding

private extension TransactionsTableViewCell {
    func bind() {
        viewModel.outputs.transactionTitle.bind(to: transactionTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactionTimeCategory.bind(to: transactionTimeCategory.rx.text).disposed(by: disposeBag)
        viewModel.outputs.currency.bind(to: currency.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactionAmount.bind(to: transactionAmount.rx.attributedText).disposed(by: disposeBag)
        // viewModel.outputs.transactionImageUrl.bind(to: transactionMerchantIconImageView.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.internationalAmount.bind(to: internationalTransactionAmount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactionAmountTextColor.subscribe(onNext: {[weak self] in
            self?.transactionAmount.textColor  = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionStatusColor.subscribe(onNext: { [weak self] in
            self?.transactionStatusLabel.textColor = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.imageContentMode.subscribe(onNext: { [weak self] in
            self?.transactionMerchantIconImageView.contentMode = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.remarks.bind(to: noteLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.transactionTypeIcon.subscribe(onNext: { [weak self] in
            self?.transactionTypeIcon.image = $0
            self?.transactionTypeIcon.isHidden = $0 == nil
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionTypeTint.subscribe(onNext: { [weak self] in
            self?.transactionTypeIcon.tintColor = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionTypeBackground.bind(to: transactionTypeIcon.rx.backgroundColor).disposed(by: disposeBag)
        
        viewModel.outputs.cancelled
            .subscribe(onNext: { [weak self] in
                if $0 {
//                    self?.transactionTitle.textColor = .grey
//                    self?.transactionTimeCategory.textColor = .grey
//                    self?.currency.textColor = .grey
//                    self?.noteLabel.textColor = .grey
                } else {
//                    self?.transactionTitle.textColor = .primaryDark
//                    self?.transactionTimeCategory.textColor = .greyDark
//                    self?.currency.textColor = .greyDark
//                    self?.noteLabel.textColor = .greyDark
                } })
            .disposed(by: disposeBag)
        
        
        viewModel.outputs.transactionStatus.subscribe(onNext: {[weak self] in
            if $0 != nil {
                self?.transactionStatusLabel.isHidden = false
                self?.transactionStatusLabel.text = $0
            }else{
                self?.transactionStatusLabel.isHidden = true
            }
        }).disposed(by: disposeBag)
        bindImageGrandientBackground()
        viewModel.outputs.shimmering.bind(to: transactionTitle.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: transactionAmount.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: transactionMerchantIconImageView.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: transactionTimeCategory.rx.isShimmerOn).disposed(by: disposeBag)
    }
    
    func bindImageGrandientBackground() {
        viewModel.outputs.addVirtualCardDesignGradient.subscribe(onNext: { [weak self] colors in
            if colors?.count == 1 {
                self?.iconContainerView.backgroundColor = colors?.first
            } else if let colors = colors, colors.count > 1 {
                self?.iconContainerView.layoutIfNeeded()
                self?.iconContainerView.setGradientBackground(colors: colors)
            }
        }).disposed(by: disposeBag)
    }
}


