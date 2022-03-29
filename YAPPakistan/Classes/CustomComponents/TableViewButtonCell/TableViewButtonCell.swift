//
//  TableViewButtonCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 17/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

public class TableViewButtonCell: RxUITableViewCell {
    
    // MARK: - Views
    lazy var button = UIFactory.makeButton(with: .regular)
    
    // MARK: Properties
    private var viewModel: TableViewButtonCellViewModelType!
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
    
    // MARK: Configration
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TableViewButtonCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
}

// MARK: Setup views
private extension TableViewButtonCell {
    func setupViews() {
        contentView.addSubview(button)
    }
    
    func setupConstraints() {
        button
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.top, constant: 30)
            .alignEdgeWithSuperview(.bottom)
            .height(constant: 52)
            .width(constant: 200)
    }
    
}

// MARK: Binding
private extension TableViewButtonCell {
    func bindViews() {
        
        viewModel.outputs.title.bind(to: button.rx.title(for: .normal)).disposed(by: disposeBag)
        
        viewModel.outputs.buttonType.unwrap().subscribe(onNext: {[weak self] type in
            
            guard let `self` = self else { return }
            
            switch type {
            case .fill:
                self.button.setTitleColor(.white, for: .normal)
                self.button.backgroundColor = UIColor(self.themeService.attrs.primary)
            case .light:
                self.button.setTitleColor(UIColor(self.themeService.attrs.primary), for: .normal)
                self.button.backgroundColor = .clear
            }
        }).disposed(by: disposeBag)
        
        button.rx.tap.bind(to: viewModel.inputs.buttonObserver).disposed(by: disposeBag)
    }
}
