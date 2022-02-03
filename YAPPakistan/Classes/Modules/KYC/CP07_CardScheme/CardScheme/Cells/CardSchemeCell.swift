//
//  CardSchemeCell.swift
//  YAPPakistan
//
//  Created by Umair  on 02/02/2022.
//

// 25 25, 325 214

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class CardSchemeCell: RxUITableViewCell {
    
    //MARK: Views
    lazy var containerView = UIFactory.makeView()
    lazy var schemeView = UIFactory.makeView(cornerRadious: 12, borderWidth: 1)
    
    lazy var cardTitle = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0)
    lazy var cardDescription = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0)
    lazy var cardImage = UIFactory.makeImageView()
    
    lazy var cardButton = UIFactory.makeAppRoundedButton(with: .micro)
    
    //MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: CardSchemeCellViewModelType!
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let vm = viewModel as? CardSchemeCellViewModelType else { return }
        self.themeService = themeService
        self.viewModel = vm
        
        setupBindings()
        setupTheme()
    }
}

extension CardSchemeCell: ViewDesignable {
    func setupSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(schemeView)
        
        schemeView.addSubview(cardTitle)
        schemeView.addSubview(cardDescription)
        schemeView.addSubview(cardImage)
        schemeView.addSubview(cardButton)
        
        selectionStyle = .none
    }
    
    func setupConstraints() {
        containerView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants:[25, 25, 0, 0])
        
        schemeView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [0, 0, 16, 16])
//            .height(constant: 182)
        
        cardTitle
            .alignEdgesWithSuperview([.left, .top], constants: [18, 18])
            .height(constant: 28)
        cardDescription
            .toBottomOf(cardTitle)
            .toLeftOf(cardImage)
            .alignEdgesWithSuperview([.left], constants: [18])
        
        cardImage
            .alignEdgesWithSuperview([.right, .top, .bottom], constants:[-11, 7, 7])
        
        cardButton
            .alignEdgesWithSuperview([.left, .bottom], constants: [18, 18])
            .width(constant: 140)
            .height(constant: 24)
    }
    
    func setupBindings() {
        self.cardTitle.text = "Matercard"
        self.cardDescription.text = "Get YAP free card and enjoy mastercard benefits"
        self.cardButton.setTitle("Get it for free", for: .normal)
        self.cardImage.image = UIImage(named: "yap-master-card", in: .yapPakistan)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.secondaryPurple) }, to: [schemeView.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [cardTitle.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [cardDescription.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [cardButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [cardButton.rx.titleColor(for: .normal)])
            .disposed(by: disposeBag)
    }
    
    
}
