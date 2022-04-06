//
//  HomeViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents
import RxDataSources
import MXParallaxHeader

class HomeViewController: UIViewController {

    // MARK: Views
    private lazy var menuButtonItem = barButtonItem(image: UIImage(named: "icon_menu_dashboard", in: .yapPakistan), insectBy:.zero)
    private lazy var searchBarButtonItem = barButtonItem(image: UIImage(named: "icon_search", in: .yapPakistan)?.asTemplate, insectBy:.zero)
    private lazy var analyticsBarButtonItem = barButtonItem(image: UIImage(named: "icon_analytics", in: .yapPakistan), insectBy:.zero)
    private lazy var userBarButtonItem = barButtonItem(image: UIImage(named: "kyc-user", in: .yapPakistan), insectBy:.zero)
    
    private lazy var balanceValueLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .left,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)
    private lazy var showButton = UIFactory.makeButton(with: .regular)
    private lazy var hideButton = UIFactory.makeButton(with: .regular)
    private lazy var balanceDateLabel = UIFactory.makeLabel(font: .micro,
                                                        alignment: .left,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)
    private lazy var separtorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var balanceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 20)
    
    private lazy var logo = UIFactory.makeImageView(image: UIImage(named: "icon_app_logo", in: .yapPakistan),
                                                    contentMode: .scaleAspectFit)
    private lazy var headingLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .center,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)

    private lazy var logoutButton = UIFactory.makeAppRoundedButton(with: .large)

    private lazy var biometryLabel = UIFactory.makeLabel(font: .regular)

    private lazy var biometrySwitch = UIFactory.makeAppSwitch()

    private lazy var biometryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [biometryLabel, biometrySwitch])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    private lazy var completeVerificationButton = UIFactory.makeAppRoundedButton(with: .large, title: "Complete verification")
    
    //with Transactions
    private lazy var parallaxHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var floatingButton: FloatingButton = {
        let button = FloatingButton()
        return button
    }()

    private lazy var alert: YAPAlert = {
        let alert = YAPAlert()
        alert.translatesAutoresizingMaskIntoConstraints = false
        return alert
    }()

    private var safeAreaOffset: CGFloat {
        (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
    }

    private var parallaxHeaderTopOffset: CGFloat {
        20
    }
    
    private var isTableViewReloaded: Bool = false

    private lazy var scrollView: MXScrollView = {
        let scrollView = MXScrollView()
        scrollView.parallaxHeader.view = parallaxHeaderView
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.delegate = self
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

//    private lazy var toolBar: HomeBalanceToolbarUpdated = {
//        let toolBar = HomeBalanceToolbarUpdated()
//        toolBar.backgroundColor = .clear
//        toolBar.delegate = self
//        toolBar.translatesAutoresizingMaskIntoConstraints = false
//        return toolBar
//    }()

    private lazy var notificationsView: NotificationsView = {
        let view = NotificationsView(theme: self.themeService)
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var welcomeView: WelcomeView = {
        let view = WelcomeView(theme: self.themeService)
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()


//    lazy var barGraphView: BarGraphView = {
//        let graph = BarGraphView()
//        graph.translatesAutoresizingMaskIntoConstraints = false
//        graph.isHidden = true
//        graph.barWidth = 8
//        return graph
//    }()
    
    private var widgetViewHeightConstraints: NSLayoutConstraint!

    private lazy var widgetView: DashboardWidgets = {
        let buttons = DashboardWidgets(theme: self.themeService)
        var res = DashboardWidgetsResponse.mock
        res.iconPlaceholder = UIImage.init(named: "icon_add_card", in: .yapPakistan)
        buttons.viewModel.inputs.widgetsDataObserver.onNext([res,res,res,res,res,res,res])
        buttons.translatesAutoresizingMaskIntoConstraints = false
        buttons.backgroundColor = .white
        return buttons
    }()
    
    private lazy var creditLimitView: CreditLimitView = {
        let view = CreditLimitView(theme: self.themeService, viewModel: self.viewModel.outputs.getCreditLimitViewModel())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerStackView = UIStackViewFactory
        .createStackView(with: .vertical,
                         alignment: .fill,
                         distribution: .fill,
                         spacing: 0,
                         arrangedSubviews: [notificationsView, widgetView])
    
    var showsNotification = false {
        didSet {
            if showsGraph {
                self.showsGraph = !self.showsNotification
            }
            self.notificationsView.isHidden = !self.showsNotification
            self.updateParallaxHeaderProgress()
        }
    }
    var showsGraph = false {
        didSet {
       //     self.barGraphView.isHidden = !(!showsNotification && showsGraph)
            self.updateParallaxHeaderProgress()
          //  viewModel.inputs.isBarGraphVisibleObserver.onNext(showsGraph)
        }
    }
    private var showsButtons = true
    private var containerViewHeightConstraint: NSLayoutConstraint!

    lazy var transactionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

//    lazy var transactionsViewModel: TransactionsViewModelType = {
//        let transactionViewModel: TransactionsViewModelType = TransactionsViewModel(transactionDataProvider: DebitCardTransactionsProvider())
//        return transactionViewModel
//    }()
//
//    lazy var transactionViewController: TransactionsViewController = {
//        let viewController = TransactionsViewController(viewModel: transactionsViewModel)
//        return viewController
//    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .clear
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    
    private lazy var profileImageView = UIFactory.createGifImageView(mode: .scaleAspectFill, image: nil, tintColor: .clear)
    private var selectionLocked: Bool = false
    
    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    var viewModel: HomeViewModelType!
    private var balanceHeight: NSLayoutConstraint!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: HomeViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = userBarButtonItem.barItem
        navigationItem.rightBarButtonItems = [menuButtonItem.barItem,searchBarButtonItem.barItem,analyticsBarButtonItem.barItem]
        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            print(self)
        }
    }
    
    @objc
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
//        SessionManager.current.refreshAccount()
//        viewModel.inputs.refreshObserver.onNext(())
    }
    
    // MARK: View Setup

    private func setupViews() {
        
        balanceView.addSubviews([balanceValueLabel,showButton,hideButton,balanceDateLabel,separtorView])
      //  containerView.addSubview(balanceView)
        containerView.addSubview(tableView)
        view.addSubview(containerView)
        
        containerView.isHidden = true
        tableView.isHidden = true
        
        view.addSubview(balanceView)
        view.addSubview(scrollView)

       // scrollView.addSubview(transactionContainer)
        scrollView.addSubview(bottomContainerView)
        parallaxHeaderView.addSubview(headerStackView)
        bottomContainerView.addSubview(welcomeView)
        bottomContainerView.addSubview(creditLimitView)
      
        
        parallaxHeaderView
            .width(with: .width, ofView: view)

        headerStackView
            .alignEdgesWithSuperview([.left, .right])
        
        scrollView
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])
            .toBottomOf(balanceView)
        notificationsView
            .alignEdgesWithSuperview([.left, .right])

//        barGraphView
//            .alignEdgesWithSuperview([.left, .right])

        widgetView
            .alignEdgesWithSuperview([.left, .right])
        widgetViewHeightConstraints = widgetView.heightAnchor.constraint(equalToConstant: 115)
        widgetViewHeightConstraints.isActive = true
        
//        containerViewHeightConstraint = transactionContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1, constant: -1 * scrollView.parallaxHeader.minimumHeight)
//        containerViewHeightConstraint.isActive = true
        containerViewHeightConstraint = bottomContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1, constant: -1 * scrollView.parallaxHeader.minimumHeight)
        containerViewHeightConstraint.isActive = true
        
        separtorView.alpha = 0
        
        tableView.register(CreditLimitCell.self, forCellReuseIdentifier: CreditLimitCell.defaultIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0)
        
      //  stack.addArrangedSubviews([balanceView, tableView])
        showButton.imageView?.contentMode = .scaleAspectFit
        showButton.setImage(UIImage.init(named: "icon_view_cell", in: .yapPakistan)?.asTemplate, for: .normal)
        hideButton.setImage(UIImage.init(named: "eye_close", in: .yapPakistan), for: .normal)
        hideButton.isHidden = true
        separtorView.alpha = 0
        separtorView.backgroundColor = .yellow
        
        balanceValueLabel.text = "PKR 50,174.78"
        balanceDateLabel.text = "Today's balance"
//        view.addSubview(logo)
//        view.addSubview(headingLabel)
//        view.addSubview(logoutButton)
//        view.addSubview(biometryStackView)
//        view.addSubview(completeVerificationButton)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: logoutButton.rx.backgroundColor,(searchBarButtonItem.button?.rx.tintColor)!)
            .bind({ UIColor($0.greyDark) }, to: [biometryLabel.rx.textColor,balanceDateLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [completeVerificationButton.rx.backgroundColor,showButton.rx.tintColor])
            .bind({ UIColor($0.primaryDark) }, to: [separtorView.rx.backgroundColor,balanceValueLabel.rx.textColor])
        
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        
        containerView
            .alignAllEdgesWithSuperview()
            //.alignEdgesWithSuperview([.left, .right, .bottom,.top])
        
        balanceView
            .height(constant: 70)
            .alignEdgesWithSuperview([.left, .top, .right], constants: [0, 0, 0])
        
        tableView
            .toBottomOf(balanceView)
            .alignEdgesWithSuperview([.left, .right,.bottom], constants: [0, 0,0])
        
        balanceValueLabel
            .alignEdgesWithSuperview([.left, .top, .right], constants: [24, 12, 24])
        
        showButton
            .height(constant: 18)
            .width(constant: 20)
            .toBottomOf(balanceValueLabel,constant: 12)
            .alignEdgesWithSuperview([.left], constants: [24])
        
        hideButton
            .height(constant: 18)
            .width(constant: 20)
            .toBottomOf(balanceValueLabel,constant: 12)
            .alignEdgesWithSuperview([.left], constants: [24])
        
        separtorView
            .height(constant: 1)
            .width(constant: 134)
            .toBottomOf(balanceValueLabel,constant: 4)
            .alignEdgesWithSuperview([.left], constants: [24])
        
       balanceDateLabel
            .height(constant: 14)
            .toRightOf(showButton,constant: 8)
            .toBottomOf(balanceValueLabel,constant: 12)
        
        balanceHeight = balanceValueLabel.heightAnchor.constraint(equalToConstant: 24)
        balanceHeight.priority = .required
        balanceHeight.isActive = true
        
//        transactionContainer
//            .alignEdgesWithSuperview([.left, .top, .bottom])
//            .width(with: .width, ofView: scrollView)
        
        bottomContainerView
            .alignEdgesWithSuperview([.left, .top, .bottom])
            .width(with: .width, ofView: scrollView)
        
        welcomeView
            .alignEdgesWithSuperview([.left, .top, .right])
            .height(constant: 94)
        
        creditLimitView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(welcomeView,constant: 12)
            .height(constant: 42)
        
       /* headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 30)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        stack
            .toBottomOf(headingLabel, constant: 30)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        collectionView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        recentBeneficiaryView
            .alignEdgesWithSuperview([.left, .right])
        
       logo
            .alignEdgeWithSuperviewSafeArea(.top, constant: 120)
            .centerHorizontallyInSuperview()

        headingLabel
            .toBottomOf(logo, constant: 40)
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .centerHorizontallyInSuperview()

        logoutButton
            .toBottomOf(headingLabel, constant: 70)
            .height(constant: 52)
            .width(constant: 250)
            .centerHorizontallyInSuperview()

        biometryStackView
            .toBottomOf(logoutButton, constant: 20)
            .width(with: .width, ofView: logoutButton)
            .centerHorizontallyInSuperview()

        completeVerificationButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 250) */
    }

    // MARK: Binding

    private func bindViewModel() {
     /*   viewModel.outputs.biometrySupported.map { $0 }.subscribe(onNext: {[unowned self] isHidden in
            self.biometryLabel.isHidden = !isHidden
            self.biometrySwitch.isHidden = !isHidden
        }).disposed(by: disposeBag)

        viewModel.outputs.biometryTitle
            .map { "Sign in with \($0 ?? "")" }
            .bind(to: biometryLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.biometry
            .bind(to: biometrySwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.headingText
            .bind(to: headingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.logOutButtonTitle
            .bind(to: logoutButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .bind(to: viewModel.inputs.logoutObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.completeVerificationHidden
            .bind(to: completeVerificationButton.rx.isHidden)
            .disposed(by: disposeBag)

        completeVerificationButton.rx.tap
            .bind(to: viewModel.inputs.completeVerificationObserver)
            .disposed(by: disposeBag)

        biometrySwitch.rx.value
            .bind(to: viewModel.inputs.biometryChangeObserver)
            .disposed(by: disposeBag) */

        viewModel.outputs.showActivity
            .bind(to: view.rx.showActivity)
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .bind(to: rx.showErrorMessage)
            .disposed(by: disposeBag)
        
        //viewModel.outputs.profilePic.bind(to: (userBarButtonItem.barItem.rx.loadImage())).disposed(by: disposeBag)
        viewModel.outputs.profilePic.subscribe(onNext: { [weak self] _arg0 in
            let (imageUrl,placeholderImg) = _arg0
            
            self?.userBarButtonItem.button?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            self?.userBarButtonItem.button?.layer.cornerRadius = (self?.userBarButtonItem.button?.frame.size.height  ?? 30 )/2
            self?.userBarButtonItem.button?.clipsToBounds = true
            
            self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
           /* if let url = imageUrl {
                self?.userBarButtonItem.button?.sd_setImage(with: url, for: .normal)
            } else {
                self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
            } */
            
        }).disposed(by: disposeBag)

        showButton.rx.tap.withUnretained(self).subscribe(onNext: { `self`, _ in
            self.animateView(balanceShown: false)
        }).disposed(by: disposeBag)
        
        hideButton.rx.tap.withUnretained(self).subscribe(onNext: { `self`, _ in
            self.animateView(balanceShown: true)
        }).disposed(by: disposeBag)

    }
    
    func getParallaxHeaderHeight() -> CGFloat {
        var height: CGFloat = 0
        height += 0
        height += !notificationsView.isHidden ? 150 : 0
        height += widgetView.isHidden ? 5 : 120
        return height
    }

    func getMinimumParallaxHeaderHeight() -> CGFloat {
        var height: CGFloat = 0
        height +=  0//!barGraphView.isHidden ? 20 : 0
        return height
    }
    
    func updateParallaxHeaderProgress() {
        let diff: CGFloat = getParallaxHeaderHeight() - getMinimumParallaxHeaderHeight()
        let actualProgress = (scrollView.parallaxHeader.contentView.bounds.height - getMinimumParallaxHeaderHeight()) / diff
        _ = showsNotification ? notificationsView.changeHeight(by: actualProgress) : nil
        startUpdatingHeader(actualProgress: actualProgress)
        refreshControl.removeFromSuperview()
        scrollView.addSubview(refreshControl)
        layoutParallaxHeader()
    }
    
    func startUpdatingHeader(actualProgress: CGFloat) {
        if self.isTableViewReloaded && actualProgress == 0 {
//            transactionsViewModel.inputs.showSectionData.onNext(())
//            transactionsViewModel.inputs.canShowDynamicData.onNext(true)
//            viewModel.inputs.increaseProgressViewHeightObserver.onNext(false)
        }
        if self.isTableViewReloaded && actualProgress > 0 {
//            transactionsViewModel.inputs.showTodaysData.onNext(())
//            transactionsViewModel.inputs.canShowDynamicData.onNext(false)
            scrollView.addSubview(refreshControl)
//            viewModel.inputs.increaseProgressViewHeightObserver.onNext(true)
        }
    }

    func layoutParallaxHeader() {
        DispatchQueue.main.async {
            self.scrollView.parallaxHeader.height = self.getParallaxHeaderHeight()
            self.scrollView.parallaxHeader.minimumHeight = self.getMinimumParallaxHeaderHeight()
            self.containerViewHeightConstraint.constant = -1 * (self.getMinimumParallaxHeaderHeight())
            self.view.layoutSubviews()
        }
    }

    func showNotifications() {
        showsNotification = true
    }

    func hideNotifications() {
        showsNotification = false
    }

     
}

private extension HomeViewController {
    func animateView(balanceShown: Bool) {
        balanceHeight.constant = balanceShown ? 24 : 0
       // delegate?.recentBeneficiaryViewWillAnimate(self)
        UIView.animate(withDuration: 0.3, animations: {
          //  self.view.layoutAllSuperViews()
            self.view.layoutAllSubviews()
            self.separtorView.alpha = !balanceShown ? 1 : 0
        }) { (completion) in
            guard completion else { return }
            self.balanceValueLabel.isHidden = !balanceShown
            self.showButton.isHidden = !balanceShown
            self.hideButton.isHidden = balanceShown
//            self.delegate?.recentBeneficiaryViewDidAnimate(self)
        }
    }
}

private extension HomeViewController {
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

}

// MARK: Parallex header delegate
extension HomeViewController: MXParallaxHeaderDelegate {
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        updateParallaxHeaderProgress()
    }
}

extension HomeViewController: MXScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        selectionLocked = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { self.selectionLocked = false }
    }
}

//extension HomeViewController: ProgressBarDidTapped {
//    func progressViewDidTapped(viewForMonth month: String) {
//        viewModel.inputs.progressViewTappedObserver.onNext(())
//    }
//}
