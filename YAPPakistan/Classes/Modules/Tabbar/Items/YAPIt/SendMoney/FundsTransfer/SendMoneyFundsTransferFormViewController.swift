//
//  SendMoneyFundsTransferFormViewController.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import YAPComponents
import RxDataSources
import RxTheme

class SendMoneyFundsTransferFormViewController: UITableViewController {

    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: SendMoneyFundsTransferViewModelType!
    
    // MARK: Initialization
    
    init(_ viewModel: SendMoneyFundsTransferViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindTableView()
        //self.view.backgroundColor = UIColor.green
    }
}

// MARK: View setup

private extension SendMoneyFundsTransferFormViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.separatorStyle = .none
           
        tableView.register(SMFTNoteCell.self, forCellReuseIdentifier: SMFTNoteCell.defaultIdentifier)
        tableView.register(SMFTChargesCell.self, forCellReuseIdentifier: SMFTChargesCell.defaultIdentifier)
        tableView.register(SMFTAmountInputCell.self, forCellReuseIdentifier: SMFTAmountInputCell.defaultIdentifier)
        tableView.register(SMFTBeneficiaryCell.self, forCellReuseIdentifier: SMFTBeneficiaryCell.defaultIdentifier)
        tableView.register(SMFTReasonCell.self, forCellReuseIdentifier: SMFTReasonCell.defaultIdentifier)
        tableView.register(SMFTAvailableBalanceCell.self, forCellReuseIdentifier: SMFTAvailableBalanceCell.defaultIdentifier)
    }
}

private extension SendMoneyFundsTransferFormViewController {
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}
