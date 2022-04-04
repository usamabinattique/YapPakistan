//
//  MoreViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents
import RxDataSources
import RxTheme
import UIKit

class MoreViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var headerView: MoreHeaderView = {
        let header = MoreHeaderView(theme: self.themeService)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    
    private lazy var centeredView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let settingsButton = UIButton(type: .custom)
    let notificationBarButtonItem = BadgedButtonItem(with: UIImage(named: "icon_notifications", in: .yapPakistan)?.asTemplate)
    
    // MARK: Properties
    
    private var cardDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var viewModel: MoreViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    init(viewModel: MoreViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsButton.setImage(UIImage(named: "icon_settings", in: .yapPakistan)?.asTemplate, for: .normal)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 26, height: 26)
        settingsButton.addTarget(self, action: #selector(self.openSettings(_:)), for: .touchUpInside)
        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        self.navigationItem.rightBarButtonItems = [settingsBarButtonItem, notificationBarButtonItem]

        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        presentTourGuideIfNeeded()
        
        notificationBarButtonItem.tapAction = { [weak self] in
            self?.viewModel.inputs.notificationObserver.onNext(())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppearObserver.onNext(())
        
        self.navigationController?.navigationBar.tintColor = UIColor(self.themeService.attrs.primary)
    }
    
    @objc
    private func openSettings(_ sender: UIButton) {
        viewModel.inputs.settingsObserver.onNext(())
    }
    
    
}

// MARK: View setup

extension MoreViewController: ViewDesignable {
    
    func setupSubViews(){
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(centeredView)
        
        centeredView.addSubview(collectionView)
        
        collectionView.register(MoreCollectionViewCell.self, forCellWithReuseIdentifier: MoreCollectionViewCell.defaultIdentifier)
        
    }
    
    func setupConstraints(){
        
        headerView
            .alignEdgesWithSuperview([.left, .safeAreaTop])
            .centerHorizontallyInSuperview()
        
        centeredView
            .alignEdgesWithSuperview([.left, .safeAreaBottom])
            .centerHorizontallyInSuperview()
            .toBottomOf(headerView, constant: 35)
        
        collectionView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgesWithSuperview([.top, .bottom], .greaterThanOrEqualTo, constant: 0)
        
        let top = collectionView.topAnchor.constraint(equalTo: centeredView.topAnchor, constant: 30)
        top.isActive = false //SessionManager.current.currentAccountType != .b2cAccount
        
        let center = collectionView.centerYAnchor.constraint(equalTo: centeredView.centerYAnchor)
        center.isActive = !top.isActive
    }
    
    func setupBindings(){
        viewModel.outputs.profileImage.bind(to: headerView.rx.profileImage).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: headerView.rx.name).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: headerView.rx.iban).disposed(by: disposeBag)
        viewModel.outputs.bic.bind(to: headerView.rx.bic).disposed(by: disposeBag)
        viewModel.outputs.accountNumber.bind(to: headerView.rx.accountNumber).disposed(by: disposeBag)
        viewModel.outputs.badgeValue.subscribe(onNext: {[weak self] in self?.notificationBarButtonItem.setBadge(with: $0 ?? "0") }).disposed(by: disposeBag)
        headerView.rx.bankDetailsTap.bind(to: viewModel.inputs.bankDetailsObserver).disposed(by: disposeBag)
        headerView.rx.imageTapped.bind(to: viewModel.inputs.settingsObserver).disposed(by: disposeBag)
        
        bindCollectionView()
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.primary) }, to: settingsButton.rx.tintColor)
            .disposed(by: disposeBag)
    }
    
}

// MARK: Binding

private extension MoreViewController {
    
    func bindCollectionView() {
        cardDataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { (_, collectionView, indexPath, viewModel) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoreCollectionViewCell.defaultIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: collectionView.rx.items(dataSource: cardDataSource)).disposed(by: disposeBag)
        
        collectionView.rx
            .delegate
            .setForwardToDelegate(self, retainDelegate: false)
        
        collectionView.rx.modelSelected(ReusableCollectionViewCellViewModelType.self).bind(to: viewModel.inputs.itemTappedObserver).disposed(by: disposeBag)
    }
}

// MARK: - Tour Guide
private extension MoreViewController {
    private func presentTourGuideIfNeeded() {
        viewModel.outputs.presentTourGuide.subscribe(onNext: { [weak self] in
            self?.presentTourGuide()
        }).disposed(by: disposeBag)
    }
    
    private func presentTourGuide() {
//        guidedTour = []
//        let accountDetailCenterPoint = headerView.bankDetailsButton.centerInWindow
//        let accountDetailTour = GuidedTour(title: "screen_more_tour_guide_bank_detail_title".localized, tourDescription: "screen_more_tour_guide_bank_detail_description".localized, circle: GuidedCircle(centerPointX: Int(accountDetailCenterPoint.x), centerPointY: Int(accountDetailCenterPoint.y), radius: 70))
//        guidedTour.append(accountDetailTour)
//
//        self.viewModel.inputs.moreHelpTourObserver.onNext(guidedTour)
    }
}

// MARK: UICollection view delegate

extension MoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}
