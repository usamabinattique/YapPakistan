//
//  WelcomeToYapCell.swift
//  YAP
//
//  Created by Zain on 15/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import UIKit
import YAPComponents
import RxSwift

class WelcomeToYapCell: RxUITableViewCell {
    
    // MARK: Views

    private lazy var iconImage = UIFactory.makeImageView(
        image: UIImage.init(named: "image_yap_it", in: .yapPakistan),
        contentMode: .scaleAspectFit
    )
    
    private lazy var title = UIFactory.makeLabel(/*with: .primaryDark, */ font: .small, text: "Welcome to YAP")
    
    private lazy var subTitle = UIFactory.makeLabel(/*with: .primaryDark, */ font: .small, text: "Tap here to get started")
    
    private lazy var titleStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .leading, distribution: .fill, spacing: 3, arrangedSubviews: [title, subTitle])
    
    // MARK: Properties
    
    private var viewModel: WelcomeToYapCellViewModelType!
    
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
    
    override func configure(with viewModel: Any) {
        guard let `viewModel` = viewModel as? WelcomeToYapCellViewModelType else { return }
        
        self.viewModel = viewModel
        bindViews()
    }
}

// MARK: View setup

private extension WelcomeToYapCell {
    func setupViews() {
        contentView.addSubview(iconImage)
        contentView.addSubview(titleStack)
    }
    
    func setupConstraints() {
        iconImage
            .alignEdgeWithSuperview(.left, constant: 10)
            .centerVerticallyInSuperview()
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo)
            .height(constant: 80)
            .width(constant: 80)
        
        titleStack
            .alignEdge(.centerY, withView: iconImage)
            .toRightOf(iconImage, constant: 10)
    }
}

// MARK: Binding

private extension WelcomeToYapCell {
    func bindViews() {
        
    }
}
