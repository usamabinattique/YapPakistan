//
//  MenuUserTableViewCell.swift
//  YAP
//
//  Created by Zain on 22/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MenuUserTableViewCell: RxUITableViewCell {
    
    private lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icon_app_logo", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomSeperator: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var packageIndicator = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var accountTypeLabel: UILabel = UIFactory.makeLabel(font: .regular)
    
    private lazy var nameLabel: UILabel = UIFactory.makeLabel(font: .small)
    
    private lazy var founderLabel: UILabel = UIFactory.makeLabel(font: .small, text: "FOUNDER")
    
    private lazy var nameStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .leading, distribution: .fill, spacing: 7, arrangedSubviews: [nameLabel, founderLabel])
    
    private lazy var dropDownButton: DropDownButton = {
        let button = DropDownButton()
        button.addTarget(self, action: #selector(dropDownAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private var viewModel: MenuUserTableViewCellViewModelType!
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
    
    // MARK: Actions
    
    @objc
    func dropDownAction(_ sender: UIButton) {
        viewModel.inputs.dropDownObserver.onNext(())
    }
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? MenuUserTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension MenuUserTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(logo)
        contentView.addSubview(seperator)
        contentView.addSubview(packageIndicator)
        contentView.addSubview(accountTypeLabel)
        contentView.addSubview(nameStack)
        contentView.addSubview(dropDownButton)
        contentView.addSubview(bottomSeperator)
    }
    
    func setupConstraints() {
        dropDownButton
            .alignEdgeWithSuperview(.right, constant: 15)
            .alignEdge(.top, withView: logo, constant: 15)
            .width(constant: 25)
            .height(constant: 25)
        
        logo
            .alignEdgesWithSuperview([.left, .top])
            .height(constant: 15)
        
        seperator
            .alignEdge(.top, withView: logo)
            .toRightOf(logo, constant: 8)
            .height(with: .height, ofView: logo)
            .width(constant: 1)
        
        packageIndicator
            .toRightOf(seperator, constant: 8)
            .width(constant: 19)
            .height(constant: 19)
            .alignEdge(.centerY, withView: logo)
        
        accountTypeLabel
            .toRightOf(packageIndicator, constant: 8)
            .alignEdge(.centerY, withView: logo)
        
        nameStack
            .toBottomOf(logo, constant: 10)
            .alignEdgeWithSuperview(.left)
            .toLeftOf(dropDownButton, constant: 15)
            
        bottomSeperator.toBottomOf(nameStack, constant: 14)
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0, 0])
            .alignEdgeWithSuperview(.bottom, constant: 5, priority: .defaultHigh)
            .height(constant: 1)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.greyLight) }, to: seperator.rx.backgroundColor)
            .bind({ UIColor($0.greyLight) }, to: bottomSeperator.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: founderLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: nameLabel.rx.textColor)
            .disposed(by: disposeBag)
    }
}

// MARK: Binding

extension MenuUserTableViewCell {
    func bindViews() {
        viewModel.outputs.package.bind(to: packageIndicator.rx.image).disposed(by: disposeBag)
        viewModel.outputs.packageType.bind(to: accountTypeLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.dropDownState.bind(to: dropDownButton.rx.buttonState).disposed(by: disposeBag)
        viewModel.outputs.isFounder.map{ !$0 }.bind(to: founderLabel.rx.isHidden).disposed(by: disposeBag)
    }
}
