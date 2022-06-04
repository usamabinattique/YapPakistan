//
//  TDTitleTableViewCell.swift
//  YAP
//
//  Created by Wajahat Hassan on 28/10/2019.
//  Copyright © 2019 YAP. All rights reserved.

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import SDWebImage
import RxTheme

public class TDTitleTableViewCell: RxUITableViewCell {

    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .title2, alignment: .left) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title2, alignment: .left)
    
    private lazy var paddingView: UIView = {
           let view = UIView()
//           view.backgroundColor = .cell
           view.translatesAutoresizingMaskIntoConstraints = false
           return view
       }()
    
    private var viewModel: TDTitleTableViewCellViewModelType!
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
//        guard let viewModel = viewModel as? TDTitleTableViewCellViewModelType else { return }
//        self.viewModel = viewModel
//        bind()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDTitleTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
//        setupTheme()
    }
    
}

// MARK: SetupViews
private extension TDTitleTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(paddingView)
    }
    
    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [20, 20, 0])
            .height(constant: 52)
        
        paddingView
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .height(constant: 7)
        
    }
    
    func bind() {
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
    }
}
