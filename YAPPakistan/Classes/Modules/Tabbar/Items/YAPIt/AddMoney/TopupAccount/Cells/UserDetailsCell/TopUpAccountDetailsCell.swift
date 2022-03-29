//
//  TopUpAccountDetailsCell.swift
//  YAP
//
//  Created by Zain on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class TopUpAccountDetailsCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .small, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var details = UIFactory.makeLabel(font: .large, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var seperator: UIView = {
        let view = UIView()
        //view.backgroundColor = .greyExtraLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 3, arrangedSubviews: [title, details])
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .micro
        button.setTitle("screen_more_bank_details_display_text_copy".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    
    var isHideCoppyButton: Bool = true
    
    private var viewModel: TopUpAccountDetailsCellViewModelType!
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
        setupSensitiveViews()
        //        setupConstraints()
    }
    
    // MARK: Configration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TopUpAccountDetailsCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        copyButton.layer.cornerRadius = copyButton.bounds.height/2
    }
    
}

// MARK: View setup

private extension TopUpAccountDetailsCell {
    func setupViews() {
        contentView.addSubview(stackView)
        contentView.addSubview(copyButton)
        contentView.addSubview(seperator)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: title.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: details.rx.textColor)
            .bind({ UIColor($0.primary).withAlphaComponent(0.14) }, to: copyButton.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: copyButton.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)
    }
    
    func setupConstraints() {
        
        title.height(constant: 18)
        
        details.height(.greaterThanOrEqualTo, constant: 28)
        
        if isHideCoppyButton == false {
            stackView
                .alignEdgesWithSuperview([.left, .top], constants: [25, 0])
            
            copyButton
                .toRightOf(stackView, .greaterThanOrEqualTo, constant: 5)
                .alignEdgeWithSuperview(.right, constant: 20)
                .height(constant: 22)
                .width(constant: 45)
                .centerVerticallyInSuperview()
                .toTopOf(seperator, constant: 10)
        }else{ stackView.alignEdgesWithSuperview([.left, .top, .right], constants: [25, 0, 25]) }
        
        seperator
            .toBottomOf(stackView, constant: 3)
            .height(constant: 1)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .alignEdgeWithSuperview(.bottom, constant: 20)
    }
    
    func setupSensitiveViews() {
        //in case of app analytics implement below mark sensitive view in YPK
        //details.markSensitive()
    }
}

// MARK: Binding

private extension TopUpAccountDetailsCell {
    func bindViews() {
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.details.bind(to: details.rx.text).disposed(by: disposeBag)
        viewModel.outputs
            .isHideCopyButton
            .do(onNext: {[weak self] in self?.isHideCoppyButton = $0; self?.setupConstraints() })
            .bind(to: copyButton.rx.isHidden).disposed(by: disposeBag)
        
        copyButton.rx.tap.bind(to: viewModel.inputs.copyObserver).disposed(by: disposeBag)
        
    }
}
