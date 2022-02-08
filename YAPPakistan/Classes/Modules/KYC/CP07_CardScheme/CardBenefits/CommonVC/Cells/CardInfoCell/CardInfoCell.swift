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
    lazy var containerView = UIFactory.makeView()
    lazy var cardIcon = UIFactory.makeImageView()
    lazy var cardTitle = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0)
    lazy var cardDescription = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0)
    lazy var labelsStack = UIFactory.makeStackView(axis: .vertical, alignment: .top, distribution: .fillProportionally, spacing: 0, arrangedSubviews: [cardTitle, cardDescription])
    
    
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
        containerView.addSubview(cardIcon)
        containerView.addSubview(labelsStack)
        contentView.addSubview(containerView)
        
        selectionStyle = .none
    }
    
    func setupConstraints() {
        
        containerView
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [0, 32, 0, 32])
        
        cardIcon
            .alignEdgesWithSuperview([.left, .top, .bottom], constants:[26, 5, 5])
            .height(constant: 66)
            .width(constant: 66)
        
        labelsStack
            .toRightOf(cardIcon, constant: 20)
            .alignEdgesWithSuperview([.top, .right, .bottom], constants: [0, 25, 0])
    }
    
    func setupBindings() {
        self.viewModel.outputs.cardTitle.bind(to: cardTitle.rx.text).disposed(by: disposeBag)
        self.viewModel.outputs.cardDescription.bind(to: cardDescription.rx.text).disposed(by: disposeBag)
        self.viewModel.outputs.cardImageIcon
            .subscribe(onNext:{ [weak self] in
                self?.cardIcon.image = UIImage(named: $0, in: .yapPakistan)
            })
            .disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [cardTitle.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [cardDescription.rx.textColor])
            .disposed(by: disposeBag)
    }
    
    
}

