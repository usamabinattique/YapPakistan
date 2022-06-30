//
//  AccountLimitCell.swift
//  YAPPakistan
//
//  Created by Umair  on 12/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class AccountLimitCell: RxUITableViewCell {
    
    // MARK: Views
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private lazy var transactionTypeLogo = UIFactory.makeImageView()
    private lazy var transactionTitle = UIFactory.makeLabel(font: .regular, numberOfLines: 0)
    private lazy var separatorView = UIFactory.makeView()
    private lazy var cellTitleView = UIFactory.makeView()
    
    private lazy var tableView: NestedTableView = {
        let tableView = NestedTableView()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    var viewModel: AccountLimitCellViewModel!
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
        setupSubViews()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupAppearance()
    }
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? AccountLimitCellViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupBindings()
        setupTheme()
        
//        containerView.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.black, radius: 2.0, opacity: 0.35)
    }
    
    
    
}

extension AccountLimitCell: ViewDesignable {
    func setupSubViews() {
        cellTitleView.addSubview(transactionTypeLogo)
        cellTitleView.addSubview(transactionTitle)
        cellTitleView.addSubview(separatorView)
        containerView.addSubview(cellTitleView)
        containerView.addSubview(tableView)
        contentView.addSubview(containerView)
        
        containerView.layer.cornerRadius = 8

        tableView.register(LimitTransactionCell.self, forCellReuseIdentifier: LimitTransactionCell.defaultIdentifier)
        
        containerView.addShadowWithCornerRadius(cornerRadius: 8)
    }
    
    func setupConstraints() {
        
        containerView
            .alignEdgesWithSuperview([.top, .left, .right, .bottom], constants: [30, 35, 35, 10])
        
        cellTitleView
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0, 0, 0])
            .height(constant: 82)
        
        transactionTypeLogo
            .alignEdgesWithSuperview([.top, .left], constants: [21, 19])
            .width(constant: 41)
            .height(constant: 41)
        
        transactionTitle
            .toRightOf(transactionTypeLogo, constant: 14)
            .alignEdgesWithSuperview([.right], constants: [14])
            .centerVerticallyInSuperview()
            .height(constant: 50)
        
        separatorView
            .toBottomOf(transactionTypeLogo, constant: 20)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [0, 0, 0])
            .height(constant: 1)
        
        tableView
            .toBottomOf(separatorView)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [0, 0 , 5])
    }
    
    func setupBindings() {
        
        print(tableView.contentSize)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        
        viewModel.outputs.logo.bind(to: transactionTypeLogo.rx.loadImage(true, isStringPath: true)).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: transactionTitle.rx.text).disposed(by: disposeBag)
        
        print(tableView.contentSize)
    }
    
    func setupTheme() {
        
        self.themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: contentView.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: transactionTitle.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: separatorView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    func setupAppearance() {
        transactionTypeLogo.roundView()
    }
}

extension AccountLimitCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: self.themeService, viewModel: cellViewModel)
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
}
