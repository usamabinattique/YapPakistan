//
//  StatementMonthTableViewCell.swift
//  YAP
//
//  Created by Zain on 17/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class StatementMonthTableViewCell: RxUITableViewCell {

    // MARK: Views
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_statement", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var monthLabel: UILabel = UIFactory.makeLabel(font: .regular)
    
    private lazy var viewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_statements_display_text_view".localized, for: .normal)
        button.titleLabel?.font = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    
    var viewModel: StatementMonthTableViewCellViewModeltype!
    var themeService: ThemeService<AppTheme>!
    
    // MAKR: Initialization
    
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
        
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? StatementMonthTableViewCellViewModeltype else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
}

// MARK: Setup views

extension StatementMonthTableViewCell: ViewDesignable {
    
    func setupSubViews(){
        contentView.addSubview(icon)
        contentView.addSubview(monthLabel)
        contentView.addSubview(viewButton)
    }
    
    func setupConstraints(){
        icon
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [25, 12, 12])
            .height(constant: 25)
            .width(constant: 25)
        
        monthLabel
            .toRightOf(icon, constant: 15)
            .centerVerticallyInSuperview()
            .toLeftOf(viewButton, constant: 15)
        
        viewButton
            .alignEdgeWithSuperview(.right, constant: 20)
            .width(constant: 45)
            .centerVerticallyInSuperview()
            .height(constant: 30)
    }
    
    func setupBindings(){
        viewModel.outputs.month.bind(to: monthLabel.rx.text).disposed(by: disposeBag)
        viewButton.rx.tap.bind(to: viewModel.inputs.viewObserver).disposed(by: disposeBag)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: icon.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: monthLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: viewButton.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)
    }
}
