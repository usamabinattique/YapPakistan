//
//  SMFTCutOffTimeCell.swift
//  YAP
//
//  Created by Zain on 23/01/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import RxSwift
import YAPComponents
import RxTheme

class SMFTCutOffTimeCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var clockIcon: UIImageView = UIFactory.makeImageView(image: UIImage.init(named: "icon_clock", in: .yapPakistan, compatibleWith: nil)?.asTemplate, tintColor: .darkGray, contentMode: .center, rendringMode: .alwaysOriginal)
    //UIImageViewFactory.createImageView(mode: .center, image: UIImage.init(named: "icon_clock", in: sendMoneyBundle, compatibleWith: nil)?.asTemplate, tintColor: .primary)
    
    private lazy var timeLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    // MARK: Properties
    
    private var viewModel: SMFTCutOffTimeCellViewModelType!
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
        setupViews()
        setupConstraints()
    }

    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTCutOffTimeCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }

}

// MARK: View setup

private extension SMFTCutOffTimeCell {
    func setupViews() {
        contentView.addSubview(clockIcon)
        contentView.addSubview(timeLabel)
    }
    
    func setupConstraints() {
        
        clockIcon
            .alignEdgeWithSuperview(.top, constant: 25)
            .centerHorizontallyInSuperview()
        
        timeLabel
            .toBottomOf(clockIcon, constant: 13)
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .bottom], constants: [28, 10])
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

// MARK: Binding

private extension SMFTCutOffTimeCell {
    func bindViews() {
        viewModel.outputs.cutOffTime.bind(to: timeLabel.rx.text).disposed(by: disposeBag)
    }
}
