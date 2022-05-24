//
//  TotalTransactionsViewController.swift
//  YAPPakistan
//
//  Created by Awais on 23/05/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class TotalTransactionsViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: TotalTransactionsViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    private lazy var stackView = UIFactory.makeStackView( axis: .vertical,
                                                          alignment: .center,
                                                          distribution: .fill,
                                                          spacing: 15 )
    
    private lazy var innerStackView = UIFactory.makeStackView( axis: .vertical,
                                                          alignment: .center,
                                                          distribution: .fill,
                                                          spacing: 3 )
    
    lazy var merchantImageView = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    lazy var merchantTitleLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    lazy var totalTransactionsAmountLabel = UIFactory.makeLabel(font: .systemFont(ofSize: 24), alignment: .center, numberOfLines: 0)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    // MARK: - Properties
    let viewModel: TotalTransactionsViewModelType
    let disposeBag: DisposeBag
    private var themeService: ThemeService<AppTheme>
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Total Transactions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        setup()
        bind()
        bindTableView()
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //viewModel.inputs.viewWillAppearObserver.onNext(())
    }
    
    override internal func onTapBackButton() {
        //viewModel.inputs.backObserver.onNext(())
    }
    
    deinit {
        print("+=+++++++de init")
    }
}

// MARK: - Setup
fileprivate extension TotalTransactionsViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [merchantTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [totalTransactionsAmountLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(merchantImageView)
        
        innerStackView.addArrangedSubview(merchantTitleLabel)
        innerStackView.addArrangedSubview(totalTransactionsAmountLabel)
        stackView.addArrangedSubview(innerStackView)
        
        view.addSubview(tableView)
        
        merchantTitleLabel.text = "DSTV"
        totalTransactionsAmountLabel.text = "PKR 780.23"
        merchantImageView.clipsToBounds = true
        merchantImageView.layer.cornerRadius = 32
        merchantImageView.contentMode = .scaleAspectFill
        
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        stackView
            .alignEdgesWithSuperview([.safeAreaTop, .safeAreaLeft, .safeAreaRight], constants: [25,25,25])
            .centerHorizontallyInSuperview()
            
        merchantImageView
            .height(constant: 64)
            .width(constant: 64)
        
        tableView
            .toBottomOf(stackView, constant: 25)
            .alignEdgesWithSuperview([.safeAreaLeft, .safeAreaRight, .safeAreaBottom], constants: [5,5,0])
        
        merchantImageView.backgroundColor = UIColor.blue
    }
}


// MARK: - Bind
fileprivate extension TotalTransactionsViewController {
    func bind() {
        viewModel.outputs.navigationTitle.subscribe(onNext: { [weak self] title in
            guard let self = self else { return }
            self.title = title
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}


