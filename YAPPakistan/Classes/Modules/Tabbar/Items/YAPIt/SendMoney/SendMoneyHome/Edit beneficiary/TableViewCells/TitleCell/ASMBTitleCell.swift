//
//  ASMBTitleCell.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

open class ASMBTitleCell: RxUITableViewCell {
    
    // MARK: Vie@objc ws
    
    public lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .left)
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: ASMBTitleCellViewModelType!
    
    // MARK: Initialization
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override public func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? ASMBTitleCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
    open func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 2, 25, 2])
    }
    
}

// MARK: View setup

extension ASMBTitleCell {
    private func setupViews() {
        contentView.addSubview(titleLabel)
    }
    func setupTheme() {
        
    }
}

// MARK: Binding

private extension ASMBTitleCell {
    func bindViews() {
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.font.bind(to: titleLabel.rx.font).disposed(by: disposeBag)
        viewModel.outputs.textAlignment.bind(to: titleLabel.rx.textAlignment).disposed(by: disposeBag)
        
        /// Setting Title color
        viewModel.outputs.cellTitleType.subscribe(onNext: { [unowned self] type in
            switch type {
            case .iban:
                themeService.rx
                    .bind({ UIColor($0.greyDark)}, to: [titleLabel.rx.textColor])
                    .disposed(by: rx.disposeBag)
            default:
                themeService.rx
                    .bind({ UIColor($0.primaryDark)}, to: [titleLabel.rx.textColor])
                    .disposed(by: rx.disposeBag)
            }
        }).disposed(by: disposeBag)
    }
}
