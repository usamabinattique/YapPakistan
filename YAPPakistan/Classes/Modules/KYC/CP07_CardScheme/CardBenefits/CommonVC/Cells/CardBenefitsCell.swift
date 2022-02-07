//
//  CardBenefitsCell.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class CardBenefitsCell: RxUITableViewCell {
    
    //MARK: Views
    lazy var tickImageView = UIFactory.makeImageView()
    lazy var benefitTitle = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 0)
    
    
    //MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: CardBenefitsCellViewModel!
    
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
        guard let vm = viewModel as? CardBenefitsCellViewModel else { return }
        self.themeService = themeService
        self.viewModel = vm
        
        setupBindings()
        setupTheme()
        setupResources()
    }
}

extension CardBenefitsCell: ViewDesignable {
    func setupSubViews() {
        contentView.addSubview(tickImageView)
        contentView.addSubview(benefitTitle)
        
        selectionStyle = .none
    }
    
    func setupConstraints() {
        tickImageView
            .alignEdgesWithSuperview([.left, .top, .bottom], constants:[30, 8, 8])
            .height(constant: 36)
            .width(constant: 36)
        
        benefitTitle
            .toRightOf(tickImageView, constant: 20)
            .alignEdgesWithSuperview([.right], constants: [25])
            .centerVerticallyInSuperview()
    }
    
    func setupBindings() {
        self.viewModel.outputs.benefitTitle.bind(to: benefitTitle.rx.text).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
//            .bind({ UIColor($0.secondaryPurple) }, to: [schemeView.rx.backgroundColor])
            .disposed(by: disposeBag)
    }
    func setupResources() {
        tickImageView.image = UIImage(named: "benefits_check", in: .yapPakistan)
    }
    
    
}
