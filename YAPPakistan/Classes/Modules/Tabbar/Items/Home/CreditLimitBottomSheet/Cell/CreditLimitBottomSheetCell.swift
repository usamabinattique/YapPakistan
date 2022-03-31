//
//  CreditLimitBottomSheetCell.swift
//  YAPPakistan
//
//  Created by Yasir on 01/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class CreditLimitBottomSheetCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var descriptionLabel = UIFactory.makeLabel(font: .micro,alignment: .center,numberOfLines: 0)
    private lazy var gotItButton = UIFactory.makeButton(with: .large, backgroundColor: .clear, title: "Got it")
    
    // MARK: Properties
    
    var viewModel: CreditLimitBottomSheetCellViewModelType!
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
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? CreditLimitBottomSheetCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension CreditLimitBottomSheetCell {
    func setupViews() {
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(gotItButton)
    }
    
    func setupConstraints() {
        descriptionLabel
            .alignEdgesWithSuperview([.left, .top, .right], constants: [20, 0, 24])
            
        gotItButton
            .height(constant: 20)
            .toBottomOf(descriptionLabel,constant: 16)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 8)
    }
    
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [gotItButton.rx.tintColor,gotItButton.rx.titleColor(for: .normal
                                                                                                      )])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
}

// MARK: Binding

private extension CreditLimitBottomSheetCell {
    func bindViews() {
        viewModel.outputs.description.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        gotItButton.rx.tap.bind(to: viewModel.inputs.gotItObserver).disposed(by: disposeBag)

    }
}
