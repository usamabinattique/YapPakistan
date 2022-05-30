//
//  TDTransactionOptionsTableViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import SDWebImage
import RxTheme

public class TDTransactionOptionsTableViewCell: RxUITableViewCell {
    
    private lazy var bottomPaddingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var parentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var actionImageContainerView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(themeService.attrs.primary) //UIColor.initials.withAlphaComponent(0.16)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var actionLogo = UIImageViewFactory.createImageView(mode: .scaleAspectFit)
    private lazy var actionTitle: UILabel = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .primary, textStyle: .small, alignment: .left)
    private lazy var actionDescription: UILabel = UIFactory.makeLabel(font: .micro, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .left)
    
    private var viewModel: TDTransactionOptionsTableViewModelType!
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
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TDTransactionOptionsTableViewModelType else { return }
//        self.viewModel = viewModel
//        bind()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDTransactionOptionsTableViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
        setupTheme()
       // setupResources()
    }
    
}

// MARK: SetupViews
private extension TDTransactionOptionsTableViewCell {
    func setupViews() {
        
        contentView.backgroundColor = .white
        actionImageContainerView.layer.cornerRadius = bounds.height/2
        actionImageContainerView.layer.masksToBounds = false
        actionImageContainerView.clipsToBounds = true
        stackView.addArrangedSubview(actionTitle)
        stackView.addArrangedSubview(actionDescription)
        parentView.addSubview(stackView)
        actionImageContainerView.addSubview(actionLogo)
        parentView.addSubview(actionImageContainerView)
        contentView.addSubview(parentView)
        contentView.addSubview(bottomPaddingView)
    }
    
    func setupConstraints() {
        
        parentView
            .alignEdgesWithSuperview([.left, .right, .top])
            .height(constant: 56)
        
        actionImageContainerView
            .height(constant: 42)
            .width(constant: 42)
            .alignEdgeWithSuperview(.left, constant: 20)
            .centerVerticallyInSuperview()
        
        stackView
            .toRightOf(actionImageContainerView, constant: 16)
            .verticallyCenterWith(actionImageContainerView)
            .alignEdgeWithSuperview(.right, constant: 20)
        
        bottomPaddingView
            .toBottomOf(parentView)
            .height(constant: 8)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        actionLogo
            .centerInSuperView()
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [actionLogo.rx.tintColor, actionTitle.rx.textColor])
            .bind({ UIColor($0.primary).withAlphaComponent(0.16) }, to: [actionImageContainerView.rx.backgroundColor])
            .bind({ UIColor($0.greyDark)}, to: [actionDescription.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupSensitiveViews() {
//        UIView.markSensitiveViews([self.contentView])
    }
    
    func bind() {
        viewModel.outputs.actionTitle.bind(to: actionTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.actionDescription.bind(to: actionDescription.rx.text).disposed(by: disposeBag)
        viewModel.outputs.actionLogo.bind(to: actionLogo.rx.image).disposed(by: disposeBag)
    }
}
