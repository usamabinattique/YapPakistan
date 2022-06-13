//
//  TransactionReceiptViewController.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class TransactionReceiptViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: TransactionReceiptViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var shareBtn = UIFactory.makeAppRoundedButton(with: .regular, title: "Share")
    
    // MARK: - Properties
    let viewModel: TransactionReceiptViewModelType
    let disposeBag: DisposeBag
    private var themeService: ThemeService<AppTheme>
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Transaction receipt"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        shareBtn.addTarget(self, action: #selector(shareScreenShotAction), for: .touchUpInside)
        setup()
        bind()
        bindTableView()
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        //self.navigationController?.dismiss(animated: true, completion: nil)
        self.viewModel.inputs.backObserver.onNext(())
    }
    
    @objc
    private func shareScreenShotAction() {
        let screenShot = self.getScreenshot(view: self.tableView)
        let imageShare = [ screenShot ]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
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
    
    private func getScreenshot(view: UIView) -> UIImage? {
        //creates new image context with same size as view
        // UIGraphicsBeginImageContextWithOptions (scale=0.0) for high res capture
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
        
        // renders the view's layer into the current graphics context
        if let context = UIGraphicsGetCurrentContext() { view.layer.render(in: context) }
        
        // creates UIImage from what was drawn into graphics context
        let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        // clean up newly created context and return screenshot
        UIGraphicsEndImageContext()
        return screenshot
    }
    
    deinit {
        print("+=+++++++de init")
    }
}

// MARK: - Setup
fileprivate extension TransactionReceiptViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
            .bind({ UIColor($0.primary) }, to: [shareBtn.rx.backgroundColor])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(shareBtn)
        tableView.register(TransactionReceiptTableViewCell.self, forCellReuseIdentifier: TransactionReceiptTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        tableView
            .alignEdgesWithSuperview([.safeAreaTop, .safeAreaRight, .safeAreaLeft], constants: [20, 20, 20])
        
        shareBtn
            .alignEdgesWithSuperview([.bottom, .left, .right], constants: [60, 108, 108])
            .toBottomOf(tableView, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 55)
    }
}


// MARK: - Bind
fileprivate extension TransactionReceiptViewController {
    func bind() {
        //        viewModel.outputs.navigationTitle.subscribe(onNext: { [weak self] title in
        //            guard let self = self else { return }
        //            self.title = title
        //        }).disposed(by: disposeBag)
        //
        //        viewModel.outputs.error.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}


