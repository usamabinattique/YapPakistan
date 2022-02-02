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

class CardSchemeCell: UITableViewCell, ReusableView {
    
    //MARK: Views
    lazy var containerView = UIFactory.makeView()
    lazy var schemeView = UIFactory.makeView(cornerRadious: 12, borderWidth: 1)
    
    lazy var cardTitle = UIFactory.makeLabel()
    lazy var cardDescription = UIFactory.makeLabel()
    lazy var cardImage = UIFactory.makeImageView()
    
    lazy var cardButton = UIFactory.makeAppRoundedButton(with: .micro)
    
    //MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: CardSchemeCellViewModel!
    private var disposeBag = DisposeBag()
    
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
        disposeBag = DisposeBag()
    }
}

extension CardSchemeCell: ViewDesignable {
    func setupSubViews() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupBindings() {
        
    }
    
    func setupTheme() {
        
    }
    
    
}
