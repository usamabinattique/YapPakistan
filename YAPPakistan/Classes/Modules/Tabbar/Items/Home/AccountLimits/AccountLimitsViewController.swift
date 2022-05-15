//
//  AccountLimitsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 10/05/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents
class AccountLimitsViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var notificationView = UIFactory.makeView()
    private lazy var notificationImage = UIFactory.makeImageView()
    private lazy var notificationTitle = UIFactory.makeLabel(font: .micro, text: "From YAP")
    private lazy var notificationDescription = UIFactory.makeLabel(font: .micro, numberOfLines: 0, text: "Hey! Just to let you know, we’ll upgrade your top up limit once we’ve successfully approved your account.")
    private lazy var notificationViewCloseBtn = UIFactory.makeButton(with: .micro)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 437
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 30, arrangedSubviews: [notificationView, tableView])
    
    private var backButton: UIButton!
    
    // MARK: - Properties
    var viewModel: AccountLimitsViewModel!
    private var themeService: ThemeService<AppTheme>!
    private var disposeBag = DisposeBag()
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: AccountLimitsViewModel) {
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

extension AccountLimitsViewController: ViewDesignable {
    func setupSubViews() {
        notificationView.addSubview(notificationTitle)
        notificationView.addSubview(notificationDescription)
        notificationView.addSubview(notificationImage)
        notificationView.addSubview(notificationViewCloseBtn)
        
        view.addSubview(stackView)
        
        notificationView.layer.cornerRadius = 8.0
        
        notificationImage.image = UIImage(named: "limits_notification", in: .yapPakistan)
        notificationViewCloseBtn.setImage(UIImage(named: "icon_close", in: .yapPakistan)?.asTemplate, for: .normal)
        
        tableView.register(AccountLimitCell.self, forCellReuseIdentifier: AccountLimitCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        stackView
            .alignAllEdgesWithSuperview()
        
        notificationView
            .alignEdgesWithSuperview([.top, .left, .right], constants: [25, 25, 25])
            .height(constant: 110)
        
        notificationImage
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [5, 15, 15])
            .width(constant: 80)
            .height(constant: 80)
        
        notificationTitle
            .toRightOf(notificationImage, constant: 7)
            .alignEdgeWithSuperview(.top, constant: 24)
            .height(constant: 18)
        
        notificationDescription
            .toRightOf(notificationImage, constant: 7)
            .toBottomOf(notificationTitle)
            .alignEdgesWithSuperview([.bottom, .right], constants: [17, 13])
            
        notificationViewCloseBtn
            .alignEdgesWithSuperview([.top, .right], constants: [7, 7])
            .width(constant: 23)
            .height(constant: 23)
        
        tableView
            .toBottomOf(notificationView, constant: 0)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [0, 0, 0])
            .widthEqualToSuperView()
        
    }
    
    func setupBindings() {
        self.title = "Account limits"
        self.view.backgroundColor = .white
        self.stackView.backgroundColor = .white
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        
        viewModel.reload.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        notificationViewCloseBtn.rx.tap
            .subscribe(onNext:{ [weak self] _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self?.notificationView.alpha = 0
                } completion: { _ in
                    UIView.animate(withDuration: 0.33) {
                        self?.notificationView.isHidden = true
                    }
                }

            }).disposed(by: disposeBag)
        
        backButton.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDiffuse) }, to: notificationView.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: notificationTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: notificationDescription.rx.textColor)
            .bind({ UIColor($0.primary) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: notificationViewCloseBtn.rx.tintColor)
            .disposed(by: disposeBag)
    }
    
}

extension AccountLimitsViewController: UITableViewDelegate, UITableViewDataSource {
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
