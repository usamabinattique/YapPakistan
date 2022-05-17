//
//  SendMoneySearchCell.swift
//  YAPPakistan
//
//  Created by Umair  on 19/01/2022.
//

import Foundation
import YAPComponents
import RxTheme
import UIKit

class SendMoneySearchCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var nickname = UIFactory.makeLabel(font: .small)
    private lazy var fullName = UIFactory.makeLabel(font: .micro)
    
    private lazy var nameStack: UIStackView = UIFactory.makeStackView(axis: .vertical, alignment: .leading, spacing: 2, arrangedSubviews: [nickname, fullName])
    
    private lazy var typeImage = UIFactory.makeImageView(contentMode: .center)
    
    private lazy var flag = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    // MARK: Properties
    
    var viewModel: SendMoneySearchCellViewModelType!
    var themeService: ThemeService<AppTheme>!
    
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
    }
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        userImage.roundView()
    }
    
    // MARK: Configurations
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SendMoneySearchCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupBindings()
        setupSubViews()
        setupConstraints()
        setupTheme()
    }
}

// MARK: View setup

extension SendMoneySearchCell: ViewDesignable {
    func setupSubViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nameStack)
        contentView.addSubview(typeImage)
        contentView.addSubview(flag)
    }
    
    func setupBindings() {
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: nickname.rx.text).disposed(by: disposeBag)
        viewModel.outputs.subTitle.bind(to: fullName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flag.rx.image).disposed(by: disposeBag)
        viewModel.outputs.tranferTypeIcon.bind(to: typeImage.rx.image).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [nickname.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [fullName.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [typeImage.rx.tintColor])
            .disposed(by: disposeBag)
    }
    
    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.top, .left, .bottom], constants: [10, 25, 10])
            .height(constant: 42)
            .width(constant: 42)
        
        nameStack
            .toRightOf(userImage, constant: 15)
            .centerVerticallyWith(userImage)
        
        flag
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: userImage)
            .height(constant: 25)
            .width(constant: 25)
        
        typeImage
            .alignEdge(.centerY, withView: userImage)
            .toLeftOf(flag, constant: 12)
            .height(constant: 26)
            .width(constant: 26)
            .toRightOf(nameStack, constant: 12)
    }
}
