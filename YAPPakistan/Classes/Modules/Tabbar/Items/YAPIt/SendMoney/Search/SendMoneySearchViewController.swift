//
//  SendMoneySearchViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 19/01/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme

class SendMoneySearchViewController: KeyboardAvoidingViewController {
    
    // MARK: Views
    
    private lazy var searchBar: AppSearchBar = {
        let searchBar = AppSearchBar()
        searchBar.autoHidesCancelButton = false
//        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
//    : AppSearchTextField = {
//        let textField = AppSearchTextField()
//        textField.placeholder = "Search"
//        textField.returnKeyType = .search
//        textField.borderStyle = .none
//        textField.backgroundColor = UIColor.greyLight.withAlphaComponent(0.35)
//        textField.font = .small
//        textField.layer.cornerRadius = 17.5
//        textField.clipsToBounds = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
    
//    private lazy var cancelButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .clear
//        button.setTitle("Cancel", for: .normal)
//        button.setTitleColor(.primary, for: .normal)
//        button.titleLabel?.font = .small
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
//    private lazy var searchStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [searchBar, cancelButton])
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: SendMoneySearchViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!

    // MARK: Initialization
    
    init(_ theme: ThemeService<AppTheme>, viewModel: SendMoneySearchViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = theme
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        view.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: View setup

private extension SendMoneySearchViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        tableView.register(SendMoneySearchCell.self, forCellReuseIdentifier: SendMoneySearchCell.defaultIdentifier)
        tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.defaultIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    func setupConstraints() {
        
        searchBar
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
        
        searchBar
            .height(constant: 35)
        
        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(searchBar)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard)
    }
}

// MARK: Binding

private extension SendMoneySearchViewController {
    func bindViews() {
        
        searchBar.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        searchBar.cancelButton.rx.tap
            .do(onNext: { [weak self] in
                self?.view.endEditing(true) })
            .bind(to: viewModel.inputs.cancelObserver)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).filter { $0 is SendMoneySearchCellViewModel }.map { $0 as! SendMoneySearchCellViewModel}
            .do(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
                self?.dismissKeyboard()
            })
            .map { $0.beneficiary }
            .bind(to: viewModel.inputs.beneficiaryObserver)
            .disposed(by: disposeBag)
    }
}
