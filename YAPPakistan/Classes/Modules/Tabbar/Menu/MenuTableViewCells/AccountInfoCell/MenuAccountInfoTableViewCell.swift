//
//  MenuAccountInfoTableViewCell.swift
//  YAP
//
//  Created by Zain on 23/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme
import UIKit

class MenuAccountInfoTableViewCell: RxUITableViewCell {
    
    private lazy var accountHeading: UILabel = UIFactory.makeLabel(font: .micro, text: "screen_menu_display_text_account".localized)
    
    private lazy var accountNumber: UILabel = UIFactory.makeLabel(font: .micro)
    
    private lazy var ibanHeading: UILabel = UIFactory.makeLabel(font: .micro, text: "IBAN")
    
    private lazy var ibanNumber: UILabel = UIFactory.makeLabel(font: .micro)
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .micro
        button.setTitle("screen_menu_display_text_share".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: MenuAccountInfoTableViewCellViewModelType!
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
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? MenuAccountInfoTableViewCellViewModelType else { return }
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

private extension MenuAccountInfoTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        
        stack.addArrangedSubview(bottomView)
        
        bottomView.addSubview(accountHeading)
        bottomView.addSubview(accountNumber)
        bottomView.addSubview(ibanHeading)
        bottomView.addSubview(ibanNumber)
        bottomView.addSubview(copyButton)
        
        contentView.addSubview(stack)
    }
    
    func setupConstraints() {
        accountHeading
            .alignEdgesWithSuperview([.left, .top], constants: [0, 15])
        
        accountNumber
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(accountHeading, constant: 5)
        
        copyButton
            .alignEdgesWithSuperview([.top, .right], constant: 15)
            .height(constant: 22)
            .width(constant: 55)
        
        ibanHeading
            .toBottomOf(accountNumber, constant: 10)
            .alignEdgeWithSuperview(.left)

        ibanNumber
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(ibanHeading, constant: 5, priority: .defaultHigh)
        
        bottomView
            .alignEdges([.left, .right], withView: stack)
        
        stack
            .alignEdgesWithSuperview([.left, .right, .top])
            .alignEdgeWithSuperview(.bottom, constant: 15, priority: .required)
        
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: accountHeading.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: accountNumber.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: ibanHeading.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: ibanNumber.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: ibanNumber.rx.textColor)
            .bind({ UIColor($0.primary).withAlphaComponent(0.14) }, to: copyButton.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: copyButton.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)
    }
}

// MARK: Binding

extension MenuAccountInfoTableViewCell {
    func bindViews() {
        viewModel.outputs.accountNumber.bind(to: accountNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: ibanNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showInfo.map { !$0 }.filter { $0 }.bind(to: bottomView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showInfo.filter { $0 }.subscribe(onNext: { [unowned self] _ in
            self.bottomView.isHidden = false
            self.bottomView.transform = CGAffineTransform(scaleX: 1, y: 0)
            UIView.animate(withDuration: 0.25, animations: { [unowned self] in
                self.bottomView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }).disposed(by: disposeBag)
        
//        viewModel.outputs.showsShareButton.map{ !$0 }.bind(to: copyButton.rx.isHidden).disposed(by: disposeBag)
        
        copyButton.rx.tap.bind(to: viewModel.inputs.shareObserver).disposed(by: disposeBag)
    }
}
