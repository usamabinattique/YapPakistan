//
//  SearchFAQsViewController.swift
//  Adjust
//
//  Created by Awais on 18/05/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import SwipeCellKit

class SearchFAQsViewController: UIViewController {
    
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
        //tableView.delegate = self
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: SearchFAQsViewModelType!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>

    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: SearchFAQsViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews()
        bindTableView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { self.searchBar.becomeFirstResponder() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.map{ $0 as? SwipeTableViewCell }.forEach{ $0?.hideSwipe(animated: true) }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: View setup

private extension SearchFAQsViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        tableView.register(FAQsTableViewCell.self, forCellReuseIdentifier: FAQsTableViewCell.defaultIdentifier)
        tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        searchBar
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
            .height(constant: 35)
        
        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(searchBar, constant: 10)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard)
    }
}

// MARK: Binding

private extension SearchFAQsViewController {
    func bindViews() {
        
        searchBar.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        searchBar.rx.cancelTap.bind(to: viewModel.inputs.cancelObserver).disposed(by: disposeBag)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell //tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).subscribe(onNext: { data in
            print(data)
            self.viewModel.inputs.tableViewItemTapped.onNext(data)
        }).disposed(by: disposeBag)
    }
}
