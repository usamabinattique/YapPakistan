//
//  EditSendMoneyBeneficiaryFormTableViewController.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 15/03/2022.
//

import Foundation
import RxSwift
import RxDataSources
import RxTheme

class EditSendMoneyBeneficiaryFormTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    private let viewModel: EditSendMoneyBeneficiaryViewModel
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,
         _ viewModel: EditSendMoneyBeneficiaryViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        setupView()
        bindTableView()
    }
}

// MARK: View Setup

extension EditSendMoneyBeneficiaryFormTableViewController {
    func setupView() {
        
        view.backgroundColor = .white
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorStyle = .none
        
        tableView.register(YapContactCell.self, forCellReuseIdentifier: YapContactCell.defaultIdentifier)
        tableView.register(ASMBTextInputCell.self, forCellReuseIdentifier: ASMBTextInputCell.defaultIdentifier)
        tableView.register(ASMBTitleCell.self, forCellReuseIdentifier: ASMBTitleCell.defaultIdentifier)
        tableView.register(ASMBBankInfoCell.self, forCellReuseIdentifier: ASMBBankInfoCell.defaultIdentifier)
    }
}

// MARK: Binding

extension EditSendMoneyBeneficiaryFormTableViewController {
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).bind(to: viewModel.inputs.cellSelectedObserver).disposed(by: disposeBag)
    }
}
