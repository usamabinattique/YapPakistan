//
//  CardSchemeViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 31/01/2022.
//

import Foundation
import RxTheme
import RxSwift
import YAPComponents

class CardSchemeViewController: UIViewController {
    
    // MARK: Views

    private lazy var titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private lazy var tableView = UIFactory.makeTableView(allowsSelection: true)
    
    //MARK: Properties
    private let themeService: ThemeService<AppTheme>
    let viewModel: CardSchemeViewModelType

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: CardSchemeViewModelType) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupTheme()
        setupBindings()
        setupConstraints()
    }
}

extension CardSchemeViewController: ViewDesignable {
    func setupSubViews() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupBindings() {
        
    }
    
    func setupTheme() {
        
    }
    
    
}
