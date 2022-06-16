//
//  DocumentMissingHeaderCell.swift
//  YAPPakistan
//
//  Created by Yasir on 09/06/2022.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import YAPComponents
import RxTheme

class DocumentMissingHeaderCell: RxUITableViewCell {
    
    
    
    private lazy var titleLable: UILabel = UIFactory.makeLabel(font: .regular)
   
    
    private var viewModel: DocumentMissingHeaderCellViewModelType!
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
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? DocumentMissingHeaderCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupTheme()
        bind()
    }
    
}

// MARK: SetupViews
private extension DocumentMissingHeaderCell {
    func setupViews() {
       
        contentView.addSubview(titleLable)
    }
    
    func setupConstraints() {
       
        
        titleLable
            .alignEdgesWithSuperview([.left, .right, .top,.bottom], constants: [32,32,24,0])
           
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDiffuse) }, to: [contentView.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [titleLable.rx.textColor])
            .disposed(by: disposeBag)
    }
    
    func bind() {
        viewModel.outputs.title.bind(to: titleLable.rx.text).disposed(by: disposeBag)
    }
}

