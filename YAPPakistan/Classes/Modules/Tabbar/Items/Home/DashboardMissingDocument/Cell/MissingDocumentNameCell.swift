//
//  MissingDocumentNameCell.swift
//  YAPPakistan
//
//  Created by Yasir on 09/06/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

final class MissingDocumentNameCell: RxUITableViewCell {
    
    // MARK: Views
   
    
    private lazy var name = UIFactory.makeLabel(font: .small)
    
    private lazy var nameStack = UIFactory.makeStackView(axis: .vertical, alignment: .leading, distribution: .fill, spacing: 4, arrangedSubviews: [name])
    private lazy var icon = UIFactory.makeImageView()
    
    // MARK: Properties
    
    var viewModel: MissingDocumentNameCellViewModelType!
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
        
        render()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? MissingDocumentNameCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension MissingDocumentNameCell {
    func setupViews() {
        contentView.addSubview(name)
        contentView.addSubview(icon)
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.init(named: "icon_check_bg_white", in: .yapPakistan)
    }
    
    func setupConstraints() {
        
        name
            .alignEdgesWithSuperview([.left, .top,.bottom], constants: [32,8,8])
        icon
            .toRightOf(name, .greaterThanOrEqualTo,constant: 12)
            .alignEdgesWithSuperview([.right],constants: [48])
            .centerVerticallyWith(name)
            .height(constant: 24)
            .aspectRatio()
    }
    
    func render() {
       
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [name.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
}

// MARK: Binding
private extension MissingDocumentNameCell {
    func bindViews() {
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        viewModel.outputs.isUploaded.map{ !$0 }.bind(to: icon.rx.isHidden).disposed(by: disposeBag)
    }
}
