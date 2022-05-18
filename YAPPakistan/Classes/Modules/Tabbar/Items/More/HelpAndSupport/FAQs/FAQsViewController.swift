//
//  FAQsViewController.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme
import RxDataSources

class FAQsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: FAQsViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var tableViewDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    // MARK: Initialization
    
    init(viewModel: FAQsViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Help & support"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        setupViews()
        setupConstraints()
        bindCollectionView()
        bindTableView()
        bindViews()
        //addBackButton(.closeEmpty)
    }
    
    // MARK: Actions
    
    // MARK: Actions
    @objc
    private func backAction() {
        //accountAlert.hide()
        //viewModel.inputs.backObserver.onNext(())
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func onTapBackButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: View setup

private extension FAQsViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(tableView)
        collectionView.register(FAQMenuItemCollectionViewCell.self, forCellWithReuseIdentifier: FAQMenuItemCollectionViewCell.defaultIdentifier)
        tableView.register(FAQsTableViewCell.self, forCellReuseIdentifier: FAQsTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        collectionView
            .alignEdgesWithSuperview([.left,.right,.top], constants: [10,10,15])
            .height(constant: 50)
            .centerHorizontallyInSuperview()
        
        tableView
            .alignEdgesWithSuperview([.left, .right,.safeAreaBottom], constants: [10,5,0])
            .toBottomOf(collectionView, constant: 10)
            .centerHorizontallyInSuperview()
        
        //tableView.backgroundColor = UIColor.red
    }
}

private extension FAQsViewController {
    func bindCollectionView() {
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [unowned self] (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        
        viewModel.outputs.dataSource.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(FAQMenuItemCollectionViewCellViewModel.self).subscribe(onNext: { [unowned self] data in
            print(data)
            self.viewModel.inputs.itemTappedObserver.onNext(data)
        }).disposed(by: disposeBag)
        
        //        viewModel.scrollToTop.subscribe(onNext: {[unowned self] in
        //            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        //        }).disposed(by: disposeBag)
        
        
    }
    
    func bindTableView() {
        tableViewDataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell //tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.tableViewDataSource.bind(to: tableView.rx.items(dataSource: tableViewDataSource)).disposed(by: disposeBag)
        
//        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).bind(to: viewModel.inputs.cellSelectedObserver).disposed(by: disposeBag)
    }
    
    func bindViews() {
        //viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
}

extension FAQsViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 30)
    }
}
