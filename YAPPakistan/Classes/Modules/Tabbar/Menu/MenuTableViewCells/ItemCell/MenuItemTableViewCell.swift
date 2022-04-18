//
//  HouseholdMenuItemTableViewCell.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MenuItemTableViewCell: RxUITableViewCell {
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var title: UILabel = UIFactory.makeLabel(font: .small)
    
    private var viewModel: MenuItemTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
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
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? MenuItemTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension MenuItemTableViewCell {
    func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(title)
        title.adjustsFontSizeToFitWidth = true
    }
    
    func setupConstraints() {
        icon
            .alignEdgesWithSuperview([.left, .top])
            .alignEdgeWithSuperview(.bottom, constant: 13, priority: .defaultHigh)
            .width(constant: 25)
            .height(constant: 25)
        
        title
            .toRightOf(icon, constant: 15)
            .alignEdge(.centerY, withView: icon)
            .alignEdgeWithSuperview(.right)
    }
}

// MARK: Binding

private extension MenuItemTableViewCell {
    func bindViews() {
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.iconColor.subscribe(onNext: { [weak self] in
            self?.icon.tintColor = $0
        }).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: title.rx.textColor)
            .disposed(by: disposeBag)
    }
}
