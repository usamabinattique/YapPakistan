//
//  TopUpAccountDetailsUserCell.swift
//  YAP
//
//  Created by Zain on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class TopUpAccountDetailsUserCell: RxUITableViewCell {
    
    // MARK: Views
//
//    private lazy var userImage = UIImageViewFactory.createBackgroundImageView(mode: .scaleAspectFill)
//
    private lazy var logo = UIFactory.makeImageView()

    private lazy var details = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "This is your YAP account summary. Use these details to transfer funds from another account into YAP.")
    
//    private lazy var borderView: UIView = {
//        let view = UIView()
//        view.layer.borderColor = UIColor.greyExtraLight.cgColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 15
//        view.clipsToBounds = true
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    // MARK: Properties
    
    private var viewModel: TopUpAccountDetailsUserCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialziation
    
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
    
    // MARK: Layouting
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        render()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
//        render()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TopUpAccountDetailsUserCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension TopUpAccountDetailsUserCell {
    private func setupViews() {
        contentView.addSubview(logo)
        contentView.addSubview(details)
//        borderView.addSubview(userImage)
//        borderView.addSubview(logo)
//        borderView.addSubview(details)
    }
    
    private func setupConstraints() {
//        borderView
//            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 20, 25, 20])
//
//        userImage
//            .alignEdgeWithSuperview(.top, constant: 8)
//            .centerHorizontallyInSuperview()
//            .height(constant: 45)
//            .width(constant: 45)
//
        logo
            .alignEdgesWithSuperview([.top], constants: [50])
            .centerHorizontallyInSuperview()
            .height(constant: 45)
//
//        details
//            .toBottomOf(logo)
//            .centerHorizontallyInSuperview()
//            .alignEdgesWithSuperview([.left, .bottom], constants: [20, 10])
        
        details
            .toBottomOf(logo, constant: 21)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [30, 30, 50])
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: details.rx.textColor)
            .disposed(by: disposeBag)
    }
    
    func setupResources() {
        logo.image = UIImage(named: "icon_app_logo", in: .yapPakistan)
    }
    
//    private func render() {
//        userImage.roundView()
//    }
}

// MARK: Binding

private extension TopUpAccountDetailsUserCell {
    func bindViews() {
//        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
    }
}


