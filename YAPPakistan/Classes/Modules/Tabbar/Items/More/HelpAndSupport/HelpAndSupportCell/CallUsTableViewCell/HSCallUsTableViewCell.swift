//
//  HSCallUsTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 02/06/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class HSCallUsTableViewCell: RxUITableViewCell {

    // MARK: Views
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.white //SessionManager.current.currentAccountType == .b2cAccount ? UIColor.primary.withAlphaComponent(0.14) : .primary
        imageView.tintColor = UIColor.white //SessionManager.current.currentAccountType == .b2cAccount ? .primary : .white
        imageView.image = UIImage(named: "icon_phone_more", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = UIFactory.makePaddingLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small)
    
    private lazy var detailLabel: UILabel = UIFactory.makeLabel(font: .micro) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, text: "")
    
    private lazy var phoneLabel: UILabel = UIFactory.makePaddingLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primary, textStyle: .small, alignment: .right)
    
    // MARK: Properties
    
    private var viewModel: HSCallUsTableViewCellViewModelType!
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
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        icon.roundView()
    }
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? HSCallUsTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
}

// MARK: View setup

private extension HSCallUsTableViewCell {
    func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(detailLabel)
    }
    
    func setupConstraints() {
        icon
            .alignEdgesWithSuperview([.left, .top], constants: [10, 10, 10])
            .height(constant: 45)
            .width(constant: 45)
        
        titleLabel
            .toRightOf(icon, constant: 5)
            .alignEdge(.centerY, withView: icon)
        
        detailLabel
            .toBottomOf(titleLabel, constant: 5)
            .alignEdge(.left, withView: titleLabel)
            .alignEdgeWithSuperview(.bottom, constant: 10)
        
        phoneLabel
            .alignEdge(.centerY, withView: icon)
            .alignEdgeWithSuperview(.right, constant: 25)
            .toRightOf(titleLabel)
            
    }
}

// MARK: Bindind

private extension HSCallUsTableViewCell {
    func bindViews() {
        //viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.phoneNumber.bind(to: phoneLabel.rx.attributedText).disposed(by: disposeBag)
    }
}
