//
//  CreditLimitPopSelectionViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 31/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxDataSources
import RxSwift
import RxTheme

class CreditLimitPopSelectionViewController: ListViewController {
    
    // MARK: Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0), right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: CreditLimitPopSelectionViewModelType!
    private var tableViewHeight: NSLayoutConstraint!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    init(_ viewModel: CreditLimitPopSelectionViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle

    override func viewDidLoad() {
        self.__heightMutiplier = 0.35
        super.viewDidLoad()

        listTitle = "What is credit limit?"
        
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews()
    }
    
    // MARK: KV Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let tableView = object as? UITableView else { return }
        guard self.tableView == tableView else { return }
        
        let targetHeight = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        guard self.tableView.bounds.height < maxAvailableHeight || targetHeight < maxAvailableHeight else { return }
        
        if !isCompletlyShown {
            self.tableViewHeight.constant = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let `self` = self else { return }
            self.tableViewHeight.constant = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            self.contentHeightChanged()
        }
    }
}

// MARK: View setup

private extension CreditLimitPopSelectionViewController {
    func setupViews() {
        container.addSubview(tableView)
        
        tableView.register(CreditLimitBottomSheetCell.self, forCellReuseIdentifier: CreditLimitBottomSheetCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        tableView
            .alignAllEdgesWithSuperview()
        
        tableViewHeight = tableView.heightAnchor.constraint(lessThanOrEqualToConstant: view.frame.size.height)//200)
        tableViewHeight.isActive = true
    }
    
    func setupTheme() {
        themeService.rx
            //.bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)}, to: [titleLabel.rx.tintColor])
            .disposed(by: rx.disposeBag)



    }
}

// MARK: Binding

private extension CreditLimitPopSelectionViewController {
    func bindViews() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
           
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.outputs.dismiss.subscribe(onNext:{ [weak self] _ in
            self?.hide()
            
        }).disposed(by: disposeBag)
        
        //tableView.rx.modelSelected(SMFTPOPCellViewModel.self).map{ $0.reason }.unwrap().bind(to: viewModel.inputs.popSelectedObserver).disposed(by: disposeBag)
//        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
}

// MARK: Table view delegate
extension CreditLimitPopSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionViewModel = viewModel.outputs.sectionViewModels[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: themeService, viewModel: sectionViewModel)
        return cell
    }
}
