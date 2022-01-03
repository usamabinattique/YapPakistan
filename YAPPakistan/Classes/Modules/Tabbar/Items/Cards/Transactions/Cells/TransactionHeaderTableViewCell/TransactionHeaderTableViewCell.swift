//
//  TransactionHeaderTableViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 28/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import YAPComponents
import RxTheme

class TransactionHeaderTableViewCell: RxUITableViewCell {
    
    private lazy var parentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var transactionDay: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .small)
    private lazy var totalAmount: UILabel = UIFactory.makeLabel(/*with: .greyDark, */ font: .small, alignment: .right)
    
    private var viewModel: TransactionHeaderTableViewCellViewModelType!
    
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
        guard let viewModel = viewModel as? TransactionHeaderTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        bind()
    }
    
}

// MARK: SetupViews
private extension TransactionHeaderTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        stackView.addArrangedSubview(transactionDay)
        stackView.addArrangedSubview(totalAmount)
        parentView.addSubview(stackView)
        contentView.addSubview(parentView)
        totalAmount.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        transactionDay.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func setupConstraints() {
        stackView
            .alignEdges([.left, .right, .top, .bottom], withView: parentView, constants: [25, 25, 0, 0])
        
        parentView
            .alignEdgesWithSuperview([.left, .right, .top])
            .height(constant: 46)
    }
    
    func bind() {
        viewModel.outputs.date.unwrap().bind(to: transactionDay.rx.text).disposed(by: disposeBag)
        viewModel.outputs.totalTransactionAmount.unwrap().bind(to: totalAmount.rx.text).disposed(by: disposeBag)
    }
}
