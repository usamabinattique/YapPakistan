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
import UIKit

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
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.register(CardSchemeCell.self, forCellReuseIdentifier: CardSchemeCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [20, 20, 20])
            .height(constant: 32)
        
        tableView
            .toBottomOf(titleLabel, constant: 8)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
    
    func setupBindings() {
        
        self.titleLabel.text = "Select a card"
        
        viewModel.outputs.optionsViewModel
            .bind(to: tableView.rx.items(cellIdentifier: CardSchemeCell.defaultIdentifier, cellType: CardSchemeCell.self)){ [weak self] (index,data,cell) in
                
                guard let self = self else { return }
                cell.configure(with: self.themeService, viewModel: data)
                
            }.disposed(by: rx.disposeBag)
        
        //        tableView.rx.modelSelected(CardSchemeCellViewModel.self)
//            .bind(to: viewModel.inputs.selectedItemObserver)
//            .disposed(by: rx.disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .disposed(by: rx.disposeBag)
    }
    
}
