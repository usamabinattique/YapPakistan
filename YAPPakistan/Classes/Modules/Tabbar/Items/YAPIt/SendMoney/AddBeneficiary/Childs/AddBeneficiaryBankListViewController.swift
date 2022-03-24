//
//  AddBeneficiaryBankListViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme
import RxDataSources

class AddBeneficiaryBankListViewController: AddBeneficiaryBankListContainerChildViewController {

    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "screen_add_beneficiary_detail_display_text_bank_name_heading".localized
        label.font = UIFont.title3
        // label.textColor = UIColor.blue //.appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Beneficiaries
    private lazy var beneficiariesView = UIFactory.makeView()
    
    private lazy var searchButton = UIFactory.makeButton(with: .small, backgroundColor: .groupTableViewBackground, title: "screen_y2y_display_text_search".localized)
    //private lazy var tableView = UIFactory.makeTableView(allowsSelection: true)
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()


    private var viewModel: AddBeneficiaryBankListViewModelType!
    private var themeService:ThemeService<AppTheme>!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!

    init(themeService:ThemeService<AppTheme>, viewModel: AddBeneficiaryBankListViewModelType?) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchButton.isEnabled = true
//        viewModel?.inputs.viewAppearedObserver.onNext(true)
//        viewModel?.inputs.stageObserver.onNext(.otp)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupConstraints()
        setupTheme()
        bindViews()

    }

    override func didPopFromNavigationController() {
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchButton.roundView()
    }
}

// MARK: View setup

extension AddBeneficiaryBankListViewController {
    func setupViews() {
        view.addSubview(headingLabel)
        view.addSubview(beneficiariesView)
        beneficiariesView.addSubview(searchButton)
        beneficiariesView.addSubview(tableView)
        
        tableView.register(AddBeneficiaryCell.self, forCellReuseIdentifier: AddBeneficiaryCell.defaultIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
    }

    func setupTheme() {
        themeService.rx
           .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.tintColor])
//            .bind({ UIColor($0.greyDark       ) }, to: [subHeadingLabel.rx.textColor])
//            .bind({ UIColor($0.greyDark       ) }, to: [timerLabel.rx.textColor])
//            .bind({ UIColor($0.primary        ) }, to: [resendButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        searchButton.setImage(UIImage(named: "icon_search", in: .yapPakistan)?.asTemplate, for: .normal)
    }
    
    func setupConstraints() {

        headingLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 16)
        
        beneficiariesView
            .alignEdgesWithSuperview([.right,.left,.bottom])
            .toBottomOf(headingLabel,constant: 20)
        
        searchButton
            .alignEdgesWithSuperview([.left, .right,.top], constants: [24, 24,0])
            .height(constant: 30)
        
        tableView
            .toBottomOf(searchButton, constant: 0)//24)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
}

// MARK: Binding

private extension AddBeneficiaryBankListViewController {
    func bindViews() {
        guard let viewModel = viewModel else { return }
        
        searchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.searchButton.isEnabled = false
            self?.viewModel.inputs.searchObserver.onNext(())
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (data, tableView, index, viewModel) in
            
            guard let self = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(AddBeneficiaryCellViewModel.self)
            .map{ $0.bank }
            .bind(to: viewModel.inputs.cellSelected)
            .disposed(by: rx.disposeBag)
    }
}
