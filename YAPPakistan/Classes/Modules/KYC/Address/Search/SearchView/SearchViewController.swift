//
//  SearchViewController.swift
//  YAP
//
//  Created by Zain on 10/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

// swiftlint:disable line_length

import UIKit
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme

class SearchViewController: UIViewController {
    
    // MARK: Views
    private lazy var searchBar: AppSearchBar = {
        let searchBar = AppSearchBar()
        searchBar.autoHidesCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties

    private var cellTypes: [UITableViewCell.Type] = []
    private var themeService: ThemeService<AppTheme>!
    var viewModel: SearchViewModelType!

    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: SearchViewModelType) { /// , cells: [UITableViewCell.Type]) {
        super.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
        /// self.cellTypes = cells
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { self.searchBar.becomeFirstResponder() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// tableView.visibleCells.map{ $0 as? SwipeTableViewCell }.forEach{ $0?.hideSwipe(animated: true) }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: View setup

private extension SearchViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(tableView)

        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.defaultIdentifier)

//        cellTypes.forEach { cellType in
//            let typeString = String(describing: type(of: cellTypes[0].self))
//            tableView.register(cellType, forCellReuseIdentifier: typeString)
//        }
        /// tableView.register(SendMoneyHomeBeneficiaryCell.self, forCellReuseIdentifier: SendMoneyHomeBeneficiaryCell.reuseIdentifier)
        /// tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.reuseIdentifier)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primary) }, to: [ searchBar.cancelButton.rx.titleColor(for: .normal) ])
            .bind({ UIColor($0.greyDark) }, to: [ searchBar.textField.searchIconView.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        searchBar
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
            .height(constant: 35)
        
        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(searchBar, constant: 5)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard)
    }
}

// MARK: Binding

private extension SearchViewController {
    func bindViews() {
        searchBar.cancelButton.rx.tap.bind(to: viewModel.inputs.cancelObserver).disposed(by: rx.disposeBag)

        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        let cellsBindingResult = viewModel.outputs.cellViewModels
            .bind(to: tableView.rx.items(cellIdentifier: SearchCell.defaultIdentifier, cellType: SearchCell.self))
        cellsBindingResult { [weak self] _, viewModel, cell in
            guard let self = self else { return }
            cell.configure(with: self.themeService, viewModel: viewModel)
        }.disposed(by: rx.disposeBag)
    }
}
