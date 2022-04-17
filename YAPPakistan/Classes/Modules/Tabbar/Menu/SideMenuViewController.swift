//
//  SideMenuViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 15/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import YAPComponents
import RxTheme

public class SideMenuViewController: UIViewController {

    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var accountsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = false
        return tableView
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(named: "icon_settings", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var logoutButton: UIButton = UIFactory.makeButton(with: .large, title: "screen_user_profile_button_logout".localized)

    let disposeBag = DisposeBag()
    var menuDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    var accountDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    var viewModel: SideMenuViewModelType!
    var themeService: ThemeService<AppTheme>!

    // MARK: Initialization

    public init(themeService: ThemeService<AppTheme>, viewModel: SideMenuViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
        self.themeService = themeService
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
}

extension SideMenuViewController: ViewDesignable {
    
    public func setupSubViews() {
        view.backgroundColor = .white
        
        view.addSubview(settingsButton)
        view.addSubview(menuTableView)
        view.addSubview(separator)
        view.addSubview(accountsTableView)
        view.addSubview(logoutButton)
        
        menuTableView.register(MenuUserTableViewCell.self, forCellReuseIdentifier: MenuUserTableViewCell.defaultIdentifier)
        menuTableView.register(MenuSeparatorTableViewCell.self, forCellReuseIdentifier: MenuSeparatorTableViewCell.defaultIdentifier)
        menuTableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: MenuItemTableViewCell.defaultIdentifier)
        menuTableView.register(MenuAccountInfoTableViewCell.self, forCellReuseIdentifier: MenuAccountInfoTableViewCell.defaultIdentifier)
        accountsTableView.register(UserAccountTableViewCell.self, forCellReuseIdentifier: UserAccountTableViewCell.defaultIdentifier)
        
    }
    
    public func setupConstraints() {
        
        let safeAreaInsests = UIWindow().safeAreaInsets
        
        accountsTableView
            .alignEdgesWithSuperview([.top, .right], constants: [safeAreaInsests.top, 0])
            .toTopOf(settingsButton, constant: 15)
            .width(constant: 70)
        
        separator
            .toLeftOf(accountsTableView)
            .alignEdgesWithSuperview([.top, .bottom])
            .width(constant: 1)
        
        menuTableView
            .alignEdgesWithSuperview([.top, .left], constants: [safeAreaInsests.top, 25])
            .toLeftOf(separator)
        
        logoutButton
            .toBottomOf(menuTableView, constant: 10)
            .alignEdgeWithSuperview(.bottom, constant: safeAreaInsests.bottom == 0 ? 25 : safeAreaInsests.bottom + 15)
            .alignEdge(.centerX, withView: menuTableView)
        
        settingsButton
        .alignEdgeWithSuperview(.right, constant: 15)
        .alignEdge(.centerY, withView: logoutButton)
        .height(constant: 35)
        .toRightOf(separator, constant: 15)
            
        
        logoutButton.setContentCompressionResistancePriority(.required, for: .vertical)
        menuTableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        accountsTableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    public func setupBindings() {
        bindTableView()
        bindOutputs()
        bindUpdate()
    }
    
    public func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primary) }, to: logoutButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.greyLight) }, to: separator.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: settingsButton.rx.tintColor)
            .disposed(by: disposeBag)
    }
}

// MARK: Bind views

private extension SideMenuViewController {
    func bindTableView() {
        menuDataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        accountDataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.menuCellViewModels.bind(to: menuTableView.rx.items(dataSource: menuDataSource)).disposed(by: disposeBag)
        
        viewModel.outputs.accountCellViewModels.bind(to: accountsTableView.rx.items(dataSource: accountDataSource)).disposed(by: disposeBag)
    }
    
    func bindOutputs() {
        menuTableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).filter { $0 is MenuItemTableViewCellViewModelType}.map { ($0 as! MenuItemTableViewCellViewModel).menuItemType }.bind(to: viewModel.inputs.menuItemSelectedObserver).disposed(by: disposeBag)
        
//        menuTableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).filter { $0 is HouseholdMenuItemTableViewCellViewModelType}.map { ($0 as! HouseholdMenuItemTableViewCellViewModel).menuItemType }.bind(to: viewModel.inputs.menuItemSelectedObserver).disposed(by: disposeBag)
        
        accountsTableView.rx.modelSelected(UserAccountTableViewCellViewModel.self).map { $0.account }.bind(to: viewModel.inputs.accountSelectedObserver).disposed(by: disposeBag)
        
        settingsButton.rx.tap.bind(to: viewModel.inputs.settingsObserver).disposed(by: disposeBag)
        logoutButton.rx.tap.bind(to: viewModel.inputs.logoutObserver).disposed(by: disposeBag)
    }
    
    func bindUpdate() {
        viewModel.outputs.update.subscribe(onNext: { [unowned self] _ in
            self.menuTableView.beginUpdates()
            self.menuTableView.endUpdates()
        }).disposed(by: disposeBag)
    }
}
