//
//  CardInfoCell.swift
//  YAPPakistan
//
//  Created by Umair  on 08/02/2022.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class CardInfoCell: RxUITableViewCell {
    
    //MARK: Views
    lazy var cardIcon = UIFactory.makeImageView()
    lazy var cardTitle = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 0)
    lazy var cardDescription = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 0)
    
    
    //MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: CardInfoCellViewModel!
    
    //MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupSubViews()
        setupConstraints()
    }
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let vm = viewModel as? CardInfoCellViewModel else { return }
        self.themeService = themeService
        self.viewModel = vm
        
        setupBindings()
        setupTheme()
        setupResources()
    }
}

extension CardInfoCell: ViewDesignable {
    func setupSubViews() {
        contentView.addSubview(cardIcon)
        contentView.addSubview(cardTitle)
        contentView.addSubview(cardDescription)
        
        selectionStyle = .none
    }
    
    func setupConstraints() {
        cardIcon
            .alignEdgesWithSuperview([.left, .top, .bottom], constants:[26, 33, 34])
            .height(constant: 66)
            .width(constant: 66)
        
        cardTitle
            .toRightOf(cardIcon, constant: 20)
            .alignEdgesWithSuperview([.right], constants: [25])
            .centerVerticallyInSuperview()
        
        cardTitle
            .toRightOf(cardIcon, constant: 20)
            .alignEdgesWithSuperview([.right], constants: [25])
            .centerVerticallyInSuperview()
    }
    
    func setupBindings() {
        self.viewModel.outputs.benefitTitle.bind(to: cardTitle.rx.text).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
//            .bind({ UIColor($0.secondaryPurple) }, to: [schemeView.rx.backgroundColor])
            .disposed(by: disposeBag)
    }
    func setupResources() {
        cardIcon.image = UIImage(named: "benefits_check", in: .yapPakistan)
    }
    
    
}

