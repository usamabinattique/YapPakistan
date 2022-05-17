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
    
    // MARK: Properties
    
    private var viewModel: FAQsViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
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
        collectionView.register(FAQMenuItemCollectionViewCell.self.self, forCellWithReuseIdentifier: FAQMenuItemCollectionViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        collectionView
            .alignEdgesWithSuperview([.left,.right,.top], constants: [10,10,15])
            .height(constant: 50)
        
    }
}

private extension FAQsViewController {
    func bindTableView() {
        
//        let cities = Observable.of(["Lisbon", "Copenhagen", "London", "Madrid", "Vienna"])
//        
//        cities
//            .bind(to: collectionView.rx.items) { (collectionView, row, element) in
//                let indexPath = IndexPath(row: row, section: 0)
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FAQMenuItemCollectionViewCell", for: indexPath) as! FAQMenuItemCollectionViewCell
//                //cell.value?.text = "\(element) @ \(row)"
//                cell.menuTitle.text = element
//                return cell
//            }
//            .disposed(by: disposeBag)
        
        
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
    
    func bindViews() {
        //viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
}

extension FAQsViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 40)
    }
}
