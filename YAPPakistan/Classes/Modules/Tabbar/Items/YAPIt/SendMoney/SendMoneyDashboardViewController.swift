//
//  SendMoneyDashboardViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 04/01/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxCocoa
import RxSwift
import RxDataSources
import RxTheme

class SendMoneyDashboardViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var closeBarButtonItem = barButtonItem(image: UIImage(named: "icon_close", in: .yapPakistan), insectBy:.zero)
    private lazy var searchBarButtonItem = barButtonItem(image: UIImage(named: "icon_search_beneficiaries", in: .yapPakistan), insectBy:.zero)
    
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center)
    
//    private lazy var recentBeneficiaryView: RecentBeneficiaryView = {
//        let view = RecentBeneficiaryView()
//        view.showsSaperator = false
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var stack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 20)
    
    //MARK: Properties
    
    private var themeService: ThemeService<AppTheme>
    private var recentBeneficiaryView: RecentBeneficiaryView!
    private var viewModel: SendMoneyDashboardViewModel!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    //MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: SendMoneyDashboardViewModel, recentBeneficiaryView: RecentBeneficiaryView) {
        self.viewModel = viewModel
        self.themeService = themeService
        self.recentBeneficiaryView = recentBeneficiaryView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Send money"
        
        closeBarButtonItem.button?.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        searchBarButtonItem.button?.addTarget(self, action: #selector(search), for: .touchUpInside)
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.refreshObserver.onNext(())
    }
    
    @objc internal override func onTapBackButton() {
        self.dismiss(animated: true, completion: nil)
//        viewModel.inputs.closeObserver.onNext(())
    }
    
    @objc private func search(_ sender: Any) {
        viewModel.inputs.searchObserver.onNext(())
    }
    
}

fileprivate extension SendMoneyDashboardViewController {
    func setupSubViews() {
        navigationItem.leftBarButtonItem = closeBarButtonItem.barItem
        navigationItem.rightBarButtonItem = searchBarButtonItem.barItem
        
        view.addSubview(headingLabel)
        view.addSubview(stack)
        
        collectionView.register(YapItTileCell.self, forCellWithReuseIdentifier: YapItTileCell.defaultIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        view.backgroundColor = .white
        headingLabel.adjustsFontSizeToFitWidth = true
        
        stack.addArrangedSubviews([recentBeneficiaryView, collectionView])
    }
    
    func setupConstraints() {
        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 30)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        stack
            .toBottomOf(headingLabel, constant: 30)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        collectionView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        recentBeneficiaryView
            .alignEdgesWithSuperview([.left, .right])
        
        headingLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func setupBindings() {
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        viewModel.outputs.cellViewModels.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
//        collectionView.rx.modelSelected(YapItTileCellViewModel.self).subscribe(on: MainScheduler.instance).map{ $0.action }.bind(to: viewModel.inputs.actionObserver).disposed(by: rx.disposeBag)
        
        collectionView.rx.modelSelected(YapItTileCellViewModel.self)
            .subscribe(onNext: { model in
                self.viewModel.inputs.actionObserver.onNext(model.action)
            })
            .disposed(by: rx.disposeBag)
        
        
        
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showsRecentBeneficiary.map{ !$0 }.bind(to: recentBeneficiaryView.rx.isHidden).disposed(by: rx.disposeBag)
        recentBeneficiaryView.configure(with: self.themeService, viewModel: viewModel.outputs.recentBeneficiaryViewModel)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
        
    }
    
    func setupResources() {
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark)}, to: [searchBarButtonItem.barItem.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupLocalizedStrings() {
        
    }
}

extension SendMoneyDashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 18)/2, height: 120)
    }
}
