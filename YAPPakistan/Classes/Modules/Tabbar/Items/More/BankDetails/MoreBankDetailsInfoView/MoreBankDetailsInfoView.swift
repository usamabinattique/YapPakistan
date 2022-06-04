//
//  MoreBankDetailsInfoView.swift
//  YAPPakistan
//
//  Created by Awais on 28/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxCocoa
import UIKit
import RxTheme

class MoreBankDetailsInfoView: UIView {
    
    // MARK: Views
    
    fileprivate lazy var title: UILabel = UIFactory.makeLabel(font: .small)
    
    fileprivate lazy var details: UILabel =  UIFactory.makeLabel(font: .small, alignment: .right, lineBreakMode: .byWordWrapping)
    
    fileprivate lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_copy", in: .yapPakistan), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    
    var titleText: String? {
        didSet {
            title.text = titleText
        }
    }
    
    var titleColor: UIColor? {
        didSet {
            title.textColor = titleColor
        }
    }
    
    var detailText: String? {
        didSet {
            details.text = titleText
        }
    }
    
    var canCopy: Bool? {
        didSet {
            self.copyButton.isHidden = !(canCopy ?? true)
        }
    }
    
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
        title.font = .small
        bindViews()
    }
}

private extension MoreBankDetailsInfoView {
    func bindViews() {
        copyButton.rx.tap.subscribe(onNext: {
            UIPasteboard.general.string = self.details.text
            YAPToast.show("Copied to clipboard")
        }).disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        addSubview(title)
        addSubview(details)
        addSubview(copyButton)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)
        details.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func setupConstraints() {
        title
            .alignEdgeWithSuperview(.left)
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 5)
        
        details
            .toBottomOf(title, constant: 5)
            .alignEdgeWithSuperview(.left, constant: 0)
            .alignEdgeWithSuperview(.bottom, constant: 8)
            
        copyButton
            .alignEdgeWithSuperview(.right, constant: 5)
            .height(constant: 20)
            .width(constant: 20)
            .centerVerticallyInSuperview()
    }
}

// MARK: Recative

extension Reactive where Base: MoreBankDetailsInfoView {
    var title: Binder<String?> { return self.base.title.rx.text }
    var titleColor: Binder<UIColor?> { return self.base.title.rx.textColor }
    var details: Binder<String?> { return self.base.details.rx.text }
    var detailsColor: Binder<UIColor?> { return self.base.details.rx.textColor }
}

