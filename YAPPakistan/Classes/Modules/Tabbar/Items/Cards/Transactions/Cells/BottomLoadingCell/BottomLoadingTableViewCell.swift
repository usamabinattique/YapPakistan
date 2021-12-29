//
//  BottomLoadingTableViewCell.swift
//  YAPKit
//
//  Created by Zain on 24/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import YAPComponents

class BottomLoadingTableViewCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: Properties
    
    private var viewModel: BottomLoadingTableViewCellViewModelType!
    
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
    
    /* override */ func configure(with viewModel: Any) {
        guard let viewModel = viewModel as? BottomLoadingTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews()
    }
    
}

// MARK: View setup

private extension BottomLoadingTableViewCell {
    func setupViews() {
        contentView.addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        activityIndicator
            .centerInSuperView()
            .alignEdgesWithSuperview([.top, .bottom], constant: 15)
    }
}

// MARK: Binding

private extension BottomLoadingTableViewCell {
    func bindViews() {
        viewModel.outputs.indicatorStyle.subscribe(onNext: { [weak self] in
            self?.activityIndicator.style = $0
            self?.activityIndicator.startAnimating()
        }).disposed(by: disposeBag)
    }
}
