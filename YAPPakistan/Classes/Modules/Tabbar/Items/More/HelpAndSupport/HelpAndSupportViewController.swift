//
//  HelpAndSupportViewController.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme
import RxDataSources

class HelpAndSupportViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
       
    private var viewModel: HelpAndSupportViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
    // MARK: Initialization
    
    init(viewModel: HelpAndSupportViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Help & support"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        setupViews()
        setupConstraints()
        bindTableView()
        bindViews()
        //addBackButton(.closeEmpty)
    }
    
    // MARK: Actions
    
    // MARK: Actions
    @objc
    private func backAction() {
        //accountAlert.hide()
        //viewModel.inputs.backObserver.onNext(())
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func onTapBackButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: View setup

private extension HelpAndSupportViewController {
    func setupViews() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        view.addSubview(tableView)
        
        tableView.register(HelpAndSupportTableViewCell.self, forCellReuseIdentifier: HelpAndSupportTableViewCell.defaultIdentifier)
        tableView.register(HSCallUsTableViewCell.self, forCellReuseIdentifier: HSCallUsTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        tableView
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom], constants: [10,10,10,0])
    }
}

private extension HelpAndSupportViewController {
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).bind(to: viewModel.inputs.cellSelectedObserver).disposed(by: disposeBag)
    }
    
    func bindViews() {
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
}
