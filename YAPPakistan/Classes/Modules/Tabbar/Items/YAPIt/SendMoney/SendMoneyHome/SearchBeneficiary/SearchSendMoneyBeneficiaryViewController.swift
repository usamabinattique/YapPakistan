//
//  SendMoneyHomeBeneficiaryCell.swift
//  YAPPakistan
//
//  Created by Awais on 17/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import SwipeCellKit

class SearchSendMoneyBeneficiaryViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var searchBar: AppSearchBar = {
        let searchBar = AppSearchBar()
        searchBar.autoHidesCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.becomeFirstResponder()
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
    
    private var viewModel: SearchSendMoneyBeneficiaryViewModelType!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>

    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: SearchSendMoneyBeneficiaryViewModelType) {
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
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { self.searchBar.becomeFirstResponder() }
       // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.searchBar.becomeFirstResponder() }
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

private extension SearchSendMoneyBeneficiaryViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        tableView.register(SendMoneyHomeBeneficiaryCell.self, forCellReuseIdentifier: SendMoneyHomeBeneficiaryCell.defaultIdentifier)
        tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        searchBar
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
            .height(constant: 35)
        
        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(searchBar)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard)
    }
}

// MARK: Binding

private extension SearchSendMoneyBeneficiaryViewController {
    func bindViews() {
        
        searchBar.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        searchBar.rx.cancelTap
            .do(onNext: { [weak self] in
                self?.dismissKeyboard()
                self?.navigationController?.popViewController(animated: true) })
            .bind(to: viewModel.inputs.cancelObserver)
            .disposed(by: disposeBag)
        
        viewModel.outputs.cancelPressFromSenedMoneyFundTransfer.delay(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance).subscribe(onNext:{[weak self] _ in
            self?.searchBar.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            //(cell as? SwipeTableViewCell)?.delegate = self
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SendMoneyHomeBeneficiaryCellViewModel.self)
            .do(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
                self?.dismissKeyboard()
            })
            .map { $0.beneficiary }
            .bind(to: viewModel.inputs.beneficiaryObserver)
            .disposed(by: disposeBag)

    }
}

// MARK: Swipe cell delegate

extension SearchSendMoneyBeneficiaryViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let edit = SwipeAction(style: .default, title: "screen_send_money_display_text_edit".localized) { (_, indexPath) in
            
            
            
//            self.viewModel.inputs.editBeneficiaryObserver.onNext(((tableView.cellForRow(at: indexPath) as! SendMoneyHomeBeneficiaryCell).viewModel as! SendMoneyHomeBeneficiaryCellViewModel).beneficiary)
            
            
            
        }
        edit.backgroundColor = UIColor.red
        edit.image = UIImage.init(named: "iconsLock", in: .yapPakistan, compatibleWith: nil)?.asTemplate
        
        let delete = SwipeAction(style: .default, title: "screen_send_money_display_text_delete".localized) { [unowned self] (_, indexPath) in
            self.deleteBeneficiary(at: indexPath)
        }
        
        delete.backgroundColor = UIColor.red
        delete.image = UIImage.sharedImage(named: "iconsLock")?.asTemplate
        
        return [delete, edit]
    }
}

// MARK: Delete

private extension SearchSendMoneyBeneficiaryViewController {
    func deleteBeneficiary(at indexPath: IndexPath) {
//        guard !(SessionManager.current.currentProfile?.restrictions.contains(.otpBlocked) ?? false) else {
//            UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
//            return
//        }
//
//        showAlert(message: "Are you sure you want to delete this beneficiary?", defaultButtonTitle: "common_button_cancel".localized, secondayButtonTitle: "screen_send_money_display_text_delete".localized, defaultButtonHandler: nil, secondaryButtonHandler: { _ in
//            self.viewModel.inputs.deleteBeneficiaryObserver.onNext(((self.tableView.cellForRow(at: indexPath) as! SendMoneyHomeBeneficiaryCell).viewModel as! SendMoneyHomeBeneficiaryCellViewModel).beneficiary)
//        }, completion: nil)
    }
}
