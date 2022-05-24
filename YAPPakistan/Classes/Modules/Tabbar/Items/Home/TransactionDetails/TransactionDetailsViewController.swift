//
//  TransactionDetailsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents

class TransactionDetailsViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var headerView = UIFactory.makeView()
    private lazy var headerBackgroundImage = UIFactory.makeImageView()
    private lazy var headerLogoImage = UIFactory.makeImageView()
    private lazy var headerShareBtn = UIFactory.makeButton(with: .micro)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 437
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 30, arrangedSubviews: [headerView, tableView])
    
    private var backButton: UIButton!
    
    // MARK: - Properties
    var viewModel: TransactionDetailsViewModel!
    private var themeService: ThemeService<AppTheme>!
    private var disposeBag = DisposeBag()
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: TransactionDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = addBackButton(of: .closeEmpty)
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        setupResources()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchDataObserver.onNext(())
    }
    
}

extension TransactionDetailsViewController: ViewDesignable {
    func setupSubViews() {
        headerView.addSubview(headerBackgroundImage)
        headerView.addSubview(headerLogoImage)
        headerView.addSubview(headerShareBtn)
        
        view.addSubview(stackView)
        
        headerLogoImage.layer.cornerRadius = headerLogoImage.frame.size.height/2
        headerLogoImage.backgroundColor = .red
        
        headerBackgroundImage.backgroundColor = .yellow
        
        headerShareBtn.setImage(UIImage(named: "icon_share", in: .yapPakistan), for: .normal)
        
        tableView.register(AccountLimitCell.self, forCellReuseIdentifier: AccountLimitCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        stackView
            .alignAllEdgesWithSuperview()
        
        headerView
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0, 0, 0])
            .height(constant: 212)
        
        headerBackgroundImage
            .alignAllEdgesWithSuperview()
        
        headerLogoImage
            .alignEdgesWithSuperview([.bottom, .left], constants: [24, 24])
            .height(constant: 64)
            .width(constant: 64)
        
        headerShareBtn
            .alignEdgesWithSuperview([.safeAreaTop, .right], constants: [0, 25])
            .height(constant: 32)
            .width(constant: 32)
        
        tableView
            .toBottomOf(headerView, constant: 0)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [0, 0, 0])
            .widthEqualToSuperView()
        
    }
    
    func setupBindings() {
//        self.title = "Account limits"
        self.view.backgroundColor = .white
        self.stackView.backgroundColor = .white
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        
        viewModel.reload.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDiffuse) }, to: headerView.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .bind({ UIColor($0.backgroundColor) }, to: tableView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
}

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: self.themeService, viewModel: cellViewModel)
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
}

