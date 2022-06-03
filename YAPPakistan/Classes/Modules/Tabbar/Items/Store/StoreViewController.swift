//
//  StoreViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import UIKit
import RxSwift
import YAPComponents
import RxCocoa
import RxTheme

class StoreViewController: UIViewController {
    
    // MARK: - Views
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var screenTitle = UIFactory.makeLabel(font: .regular, text: "screen_store_screen_title_text".localized)
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.text = "screen_store_heading_label_text".localized
        label.font = .title3
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    let viewModel: StoreViewModelType
    let themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag
    
    // MARK: - Init
    init(viewModel: StoreViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = screenTitle
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppearObserver.onNext(())
    }
}

// MARK: - Setup
extension StoreViewController: ViewDesignable {
    
    func setupSubViews(){
        
        view.backgroundColor = .white
        view.addSubview(heading)
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(StorePackageTableViewCell.self, forCellReuseIdentifier: StorePackageTableViewCell.defaultIdentifier)
       // title = "Browse Upcoming Packages"//"screen_store_screen_title_text".localized
    }
    
    func setupConstraints(){
        
        heading
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
        
        tableView
            .toBottomOf(heading)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func setupBindings(){
        bindPackages()
        bindTourGuidePresentation()
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [heading.rx.textColor,
                                                    navigationController!.navigationBar.rx.tintColor, screenTitle.rx.textColor])
            .disposed(by: disposeBag)
    }
    
    // Private action
    @objc func onShopping() {
        print("Shopping Tapped...")
        viewModel.inputs.actionObserver.onNext(())
    }
}

// MARK: - Bind
fileprivate extension StoreViewController {
    
    private func bindPackages() {
        viewModel.outputs.StoreInformationCellViewModel.bind(to: tableView.rx.items) { tableView, index, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: StorePackageTableViewCell.defaultIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        }.disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(StorePackageTableViewCellViewModel.self)
            .flatMap{ $0.selectPackage }
            .bind(to: viewModel.inputs.selectStorePackageObserver)
            .disposed(by: disposeBag)
    }
    
    private func bindTourGuidePresentation() {
        viewModel.outputs.presentTourGuide.subscribe(onNext: { [weak self] in
            //self?.presentTourGuide()
        }).disposed(by: disposeBag)
    }
}
