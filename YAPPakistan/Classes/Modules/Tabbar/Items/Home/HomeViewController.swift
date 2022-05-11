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
    private var searchBarButtonItem: UIBarButtonItem!
    private lazy var analyticsBarButtonItem = barButtonItem(image: UIImage(named: "icon_analytics", in: .yapPakistan), insectBy:.zero)
    private lazy var userBarButtonItem = barButtonItem(image: UIImage(named: "kyc-user", in: .yapPakistan), insectBy:.zero)
    
    private lazy var balanceValueLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .left,
                                                        numberOfLines: 1,
                                                        lineBreakMode: .byWordWrapping)
    private lazy var balanceLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .left,
                                                        numberOfLines: 1,
                                                        lineBreakMode: .byWordWrapping)
   // private lazy var amountStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .leading, distribution: .fill, spacing: 0, arrangedSubviews: [balanceLabel, balanceValueLabel])
    
    private lazy var showButton = UIFactory.makeButton(with: .regular)
    private lazy var hideButton = UIFactory.makeButton(with: .regular)
    private lazy var balanceDateLabel = UIFactory.makeLabel(font: .micro,
                                                        alignment: .left,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)
    
    private lazy var noTransFoundLabel = UIFactory.makeLabel(font: .large,
                                                        alignment: .center,
                                                        numberOfLines: 1,
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
    
//    private lazy var tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.separatorStyle = .none
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
    
    private lazy var stack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 20)
    
    
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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var toolBar: HomeBalanceToolbarUpdated = {
        let toolBar = HomeBalanceToolbarUpdated(theme: themeService)
        toolBar.backgroundColor = .red
        toolBar.delegate = self
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()

//    private lazy var notificationsView: NotificationsView = {
//        let view = NotificationsView(theme: self.themeService)
//        view.backgroundColor = .white
//        view.clipsToBounds = true
//        view.isHidden = true
//        return view
//    }()
    
    private lazy var welcomeView: WelcomeView = {
        let view = WelcomeView(theme: self.themeService)
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var timelineView: DashboardTimelineView = {
        let view = DashboardTimelineView(theme: self.themeService, viewModel: DashboardTimelineViewModel(DashboardTimelineModel(title: "Account verification", description: "We noticed a mistake in your application. Please re-take a new a selfie.", isSeparator: true, isSeparatorVague: false, isProgress: true, progressStatus: "in process", isWholeContainerVague: false, btnTitle: "Re-upload now", isBtnHidden: false)))
        view.translatesAutoresizingMaskIntoConstraints = false
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
        buttons.viewModel.outputs.selectedWidget.bind(to: viewModel.inputs.selectedWidgetObserver).disposed(by: disposeBag)
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
                         arrangedSubviews: [widgetView]) //[notificationsView,widgetView])
    
    var showsNotification = false {
        didSet {
            if showsGraph {
                self.showsGraph = !self.showsNotification
            }
//            self.notificationsView.isHidden = !self.showsNotification
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

    lazy var transactionsViewModel: TransactionsViewModelType = {
        let transactionViewModel: TransactionsViewModelType = viewModel.outputs.transactionsViewModelObservable
        return transactionViewModel
    }()

    lazy var transactionViewController: TransactionsViewController = {
        let viewController = TransactionsViewController(viewModel: transactionsViewModel, themeService: themeService)
        return viewController
    }()

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
    private var balanceLabelHeight: NSLayoutConstraint!
    private var toolBarHeightConstraint: NSLayoutConstraint!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var isCreditInfoAdded = false
    private var graphBottom: NSLayoutConstraint!

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
        
        
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage.init(named: "icon_search", in: .yapPakistan)?.asTemplate, for: .normal)
        searchButton.frame = CGRect(x: 0.0, y: 0.0, width: 26, height: 26)
        searchButton.addTarget(self, action: #selector(self.searchAction(_:)), for: .touchUpInside)
        searchButton.tintColor = UIColor(themeService.attrs.primary)
        searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        navigationItem.leftBarButtonItem = userBarButtonItem.barItem
        navigationItem.rightBarButtonItems = [menuButtonItem.barItem,searchBarButtonItem,analyticsBarButtonItem.barItem]
        
        setup()
      //  bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppearObserver.onNext(())
       // viewModel.inputs.viewAppearObserver.onNext(())
        updateParallaxHeaderProgress()
        self.menuButtonItem.button?.addTarget(self, action: #selector(self.menuAction(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: scrollView.bounds.height)

        transactionViewController.view.frame = transactionContainer.bounds

        let diff = getParallaxHeaderHeight() - getMinimumParallaxHeaderHeight()
        _ = (scrollView.parallaxHeader.contentView.bounds.height - getMinimumParallaxHeaderHeight()) / diff
//        render()
    }
    
    @objc
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
//        SessionManager.current.refreshAccount()
        viewModel.inputs.refreshObserver.onNext(())
    }
    
    @objc func menuAction(_ sender: UIButton) {
        viewModel.inputs.menuTapObserver.onNext(())
    }
    
//    private func render() {
//        self.profileImageView.layer.cornerRadius = 12
//        self.profileImageView.clipsToBounds = true
//    }
    
    @objc func searchAction(_ sender: UIButton) {
        viewModel.inputs.searchTapObserver.onNext(())
    }
}

// MARK: View Setup
fileprivate extension HomeViewController {
    func setup() {
        setupViews()
        setupTheme()
        setupConstraints()
        //TODO: remove following comment
        addDebitCardTimelineIfNeeded()
        
        //TODO: remove this line from here after handling transactions api success
       // addTransactionsViewController()
        bindViewModel()
    }
    
    private func setupViews() {
        
        balanceView.addSubviews([balanceLabel,balanceValueLabel,showButton,hideButton,balanceDateLabel,separtorView])
        
//        view.addSubview(balanceView)
        view.addSubview(toolBar)
        view.addSubview(balanceView)
        view.addSubview(scrollView)
        
        balanceView.isHidden = true

        scrollView.addSubview(transactionContainer)
        parallaxHeaderView.addSubview(headerStackView)
        separtorView.alpha = 0
        
    /*    tableView.register(CreditLimitCell.self, forCellReuseIdentifier: CreditLimitCell.defaultIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0) */
        
      //  stack.addArrangedSubviews([balanceView, tableView])
        showButton.imageView?.contentMode = .scaleAspectFit
        showButton.setImage(UIImage.init(named: "icon_view_cell", in: .yapPakistan)?.asTemplate, for: .normal)
        hideButton.setImage(UIImage.init(named: "eye_close", in: .yapPakistan), for: .normal)
        hideButton.isHidden = true
        separtorView.alpha = 0
        
        balanceLabel.text = "PKR"
        balanceValueLabel.text = "0.00"
        balanceDateLabel.text = "Today's balance"
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
           // .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: (searchBarButtonItem.rx.tintColor))
            .bind({ UIColor($0.greyDark) }, to: [balanceDateLabel.rx.textColor, noTransFoundLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [completeVerificationButton.rx.backgroundColor,showButton.rx.tintColor])
            .bind({ UIColor($0.primaryDark) }, to: [separtorView.rx.backgroundColor,balanceValueLabel.rx.textColor])
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        
        parallaxHeaderView
            .width(with: .width, ofView: view)
            //.height(constant: scrollView.parallaxHeader.height)

        headerStackView
            .alignEdgesWithSuperview([.left, .right,.top])
        
        scrollView
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])
            .toBottomOf(toolBar) //(balanceView)
        

//        barGraphView
//            .alignEdgesWithSuperview([.left, .right])

        widgetView
            .alignEdgesWithSuperview([.left, .right])
        widgetViewHeightConstraints = widgetView.heightAnchor.constraint(equalToConstant: 115)
        widgetViewHeightConstraints.isActive = true
        
        containerViewHeightConstraint = transactionContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1, constant: -1 * scrollView.parallaxHeader.minimumHeight)
        containerViewHeightConstraint.isActive = true
//        containerViewHeightConstraint = bottomContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1, constant: -1 * scrollView.parallaxHeader.minimumHeight)
//        containerViewHeightConstraint.isActive = true
        
        transactionContainer
            .alignEdgesWithSuperview([.left, .top, .bottom])
            .width(with: .width, ofView: scrollView)
        
        balanceView
            .height(constant: 70)
            .alignEdgesWithSuperview([.left, .top, .right], constants: [0, 0, 0])
        
        balanceLabel
            .alignEdgesWithSuperview([.left, .top], constants: [24, 12])
        
        balanceValueLabel
            .toRightOf(balanceLabel ,constant: 4)
            .centerVerticallyWith(balanceLabel)
            .alignEdgesWithSuperview([.right], .greaterThanOrEqualTo , constants: [12])
        
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
        
        
        balanceLabelHeight = balanceLabel.heightAnchor.constraint(equalToConstant: 24)
        balanceLabelHeight.priority = .required
        balanceLabelHeight.isActive = true
        
        toolBar
            .alignEdgesWithSuperview([.left, .right])
            .alignEdgeWithSuperview(.top, constant: 0)//(self.navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height)

        toolBarHeightConstraint = toolBar.heightAnchor.constraint(equalToConstant: 80)
        toolBarHeightConstraint.isActive = true
        
    }

    // MARK: Binding

    private func bindViewModel() {

        viewModel.outputs.showActivity
            .bind(to: view.rx.showActivity)
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .bind(to: rx.showErrorMessage)
            .disposed(by: disposeBag)
        
        
        viewModel.outputs.profilePic.subscribe(onNext: { [weak self] _arg0 in
            let (imageUrl,placeholderImg) = _arg0
            
            self?.userBarButtonItem.button?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            self?.userBarButtonItem.button?.layer.cornerRadius = (self?.userBarButtonItem.button?.frame.size.height  ?? 30 )/2
            self?.userBarButtonItem.button?.clipsToBounds = true
            
           // self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
            if let url = imageUrl {
                self?.userBarButtonItem.button?.sd_setImage(with: URL(string:url), for: .normal)
            } else {
                self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
            }
            
        }).disposed(by: disposeBag)

        showButton.rx.tap.withLatestFrom(viewModel.outputs.shimmering).withUnretained(self).subscribe(onNext: { `self`, isShimmering in
            guard !isShimmering else { return }
            self.animateView(balanceShown: false)
        }).disposed(by: disposeBag)
        
        hideButton.rx.tap.withLatestFrom(viewModel.outputs.shimmering).withUnretained(self).subscribe(onNext: { `self`, isShimmering in
            guard !isShimmering else { return }
            self.animateView(balanceShown: true)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.shimmering.bind(to: showButton.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: hideButton.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: balanceLabel.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: balanceValueLabel.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: balanceDateLabel.rx.isShimmerOn).disposed(by: disposeBag)
        
        viewModel.outputs.balance.bind(to: balanceValueLabel.rx.attributedText).disposed(by: disposeBag)
        
        viewModel.outputs.dashboardWidgets.bind(to: widgetView.viewModel.inputs.widgetsDataObserver).disposed(by: disposeBag)
        
        viewModel.outputs.hideWidgetsBar.subscribe(onNext: {[weak self] hide in
            if (hide) {
//                self?.widgetViewHeightConstraints.constant = 0
                self?.widgetView.isHidden = true
            }
            else {
//                self?.widgetViewHeightConstraints.constant = 115
                self?.widgetView.isHidden = false
            }
            self?.updateParallaxHeaderProgress()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.dashboardWidgets.bind(to: widgetView.rx.dashboardWidgets).disposed(by: disposeBag)
        
        widgetView.viewModel.selectedWidget.subscribe(onNext: {[weak self] in
            self?.viewModel.inputs.selectedWidgetObserver.onNext($0 ?? .unknown)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.noTransFound.withUnretained(self).subscribe(onNext:  { `self`, text in
           /* self.noTransFoundLabel.text = text
            self.transactionContainer.removeSubviews()
            self.transactionContainer.addSubview(self.noTransFoundLabel)
            self.noTransFoundLabel.alignCenterWith(self.transactionContainer) */
        }).disposed(by: disposeBag)
        
        viewModel.outputs.addCreditInfo.take(1).withUnretained(self).subscribe(onNext:  { `self`, _ in
           /* self.isCreditInfoAdded = true
            self.transactionContainer.removeSubviews()
            self.transactionContainer.addSubview(self.creditLimitView)
            self.creditLimitView.alignEdgeWithSuperview(.top, constant: 12)
            self.creditLimitView.alignEdgeWithSuperview(.left)
            self.creditLimitView.alignEdgeWithSuperview(.right)
            self.creditLimitView.height(constant: 42) */
        }).disposed(by: disposeBag)
        
//        transactionsViewModel.outputs.sectionAmount.unwrap().bind(to: self.rx.balance).disposed(by: disposeBag)
//        transactionsViewModel.outputs.sectionDate.unwrap().bind(to: self.rx.date).disposed(by: disposeBag)
//        transactionsViewModel.outputs.sectionDate.unwrap().withUnretained(self).subscribe(onNext: { (`self`, value) in
//            self.setDate(date: value)
//        }).disposed(by: disposeBag)

        
        viewModel.outputs.shrinkProgressView.bind(to: toolBar.rx.shrink).disposed(by: disposeBag)
        transactionsViewModel.outputs.categorySectionCount.bind(to: toolBar.rx.numberOfSections).disposed(by: disposeBag)
        transactionsViewModel.outputs.sectionAmount.unwrap().bind(to: toolBar.rx.balance).disposed(by: disposeBag)
        transactionsViewModel.outputs.sectionDate.unwrap().bind(to: toolBar.rx.date).disposed(by: disposeBag)
        
      /*  transactionsViewModel.outputs.categoryBarData.subscribe(onNext: { [weak self] categoryData in
           
            if categoryData.0 == nil {
                UIView.animate(withDuration: 0.8, animations: {[weak self] in
                    self?.toolBarHeightConstraint.constant = 80
                    self?.view.layoutIfNeeded()
                })
            }
            else {
                UIView.animate(withDuration: 0.8, animations: { [weak self] in
                    self?.toolBarHeightConstraint.constant = 120
                    self?.view.layoutIfNeeded()
                })
            }
            self?.toolBar.rx.monthData.onNext(categoryData)
        }).disposed(by: disposeBag) */
    }
    
    func getParallaxHeaderHeight() -> CGFloat {
        var height: CGFloat = 0
        height += 0
//        height += !notificationsView.isHidden ? 150 : 0
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
//        _ = showsNotification ? notificationsView.changeHeight(by: actualProgress) : nil
        startUpdatingHeader(actualProgress: actualProgress)
        refreshControl.removeFromSuperview()
        scrollView.addSubview(refreshControl)
        layoutParallaxHeader()
    }
    
    func startUpdatingHeader(actualProgress: CGFloat) {
        if self.isTableViewReloaded && actualProgress == 0 {
            transactionsViewModel.inputs.showSectionData.onNext(())
            transactionsViewModel.inputs.canShowDynamicData.onNext(true)
            viewModel.inputs.increaseProgressViewHeightObserver.onNext(false)
        }
        if self.isTableViewReloaded && actualProgress > 0 {
            transactionsViewModel.inputs.showTodaysData.onNext(())
            transactionsViewModel.inputs.canShowDynamicData.onNext(false)
            scrollView.addSubview(refreshControl)
            viewModel.inputs.increaseProgressViewHeightObserver.onNext(true)
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
    
    func addTransactionsViewController() {
        self.addChild(self.transactionViewController)
        self.transactionContainer.addSubview(self.transactionViewController.view)
        self.transactionViewController.view.alignAllEdgesWithSuperview()
    }
    
    func addDebitCardTimelineIfNeeded() {
        viewModel.outputs.debitCardOnboardingStageViewModel.withUnretained(self).subscribe(onNext: { `self`, stagesViewModel in
         //   guard let `self` = self else { return }
            if let stagesViewModel = stagesViewModel {
                self.transactionContainer.subviews.filter { $0 is PaymentCardOnboardingStatusView }.forEach { $0.removeFromSuperview() }
                let stagesView = PaymentCardOnboardingStatusView(theme: self.themeService, viewModel: stagesViewModel)
                self.transactionContainer.addSubview(stagesView)
                if !self.isCreditInfoAdded {
                    stagesView.alignAllEdgesWithSuperview()
                } else {
                    stagesView.alignEdgesWithSuperview([.left,.right,.bottom])
                    stagesView.toBottomOf(self.creditLimitView)
                }
                
            } else {
                self.transactionContainer.subviews.filter { $0 is PaymentCardOnboardingStatusView }.first?.removeFromSuperview()
            }}, onCompleted: { [weak self] in
                guard let `self` = self else { return }
                self.addTransactionsViewController()
        }).disposed(by: disposeBag)
        
    }
    
    func showHomeTourGuide() {

       /* let points: [DashboardTourGuide] = [

            (title :"screen_home_display_tour_guide_text_title_top_menue".localized, desc: "screen_home_display_tour_guide_text_desc_top_menue".localized, buttonTitle: nil, x: Int(self.rightBarButtonItemCenterInWindow.x), y: Int(self.rightBarButtonItemCenterInWindow.y), radius: 35),

            (title :"screen_home_display_tour_guide_text_title_amount".localized, desc: "screen_home_display_tour_guide_text_desc_amount".localized, buttonTitle: nil, x: Int(self.toolBar.ammount.centerInWindow.x), y: Int(self.toolBar.ammount.centerInWindow.y), radius: 80),

            (title :"screen_home_display_tour_guide_text_title_yap_it".localized, desc: "screen_home_display_tour_guide_text_desc_yap_it".localized, buttonTitle: nil, x: Int(UIScreen.main.bounds.width)/2, y: Int(UIScreen.main.bounds.maxY) - Int(35 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 0 ? 20 : UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)), radius: 100),

            (title :"screen_home_display_tour_guide_text_title_search".localized, desc: "screen_home_display_tour_guide_text_desc_search".localized, buttonTitle: "Finish", x: Int(self.secondLeftBarButtonItemCenterInWindow.x), y: Int(self.secondLeftBarButtonItemCenterInWindow.y), radius: 35)

        ]
        viewModel.inputs.dashboardTourGuideObserver.onNext(points) */
    }
}

fileprivate extension HomeViewController {
    func animateView(balanceShown: Bool) {
        balanceHeight.constant = balanceShown ? 24 : 0
        balanceLabelHeight.constant = balanceShown ? 24 : 0
       // delegate?.recentBeneficiaryViewWillAnimate(self)
        UIView.animate(withDuration: 0.3, animations: {
          //  self.view.layoutAllSuperViews()
            self.view.layoutAllSubviews()
            self.separtorView.alpha = !balanceShown ? 1 : 0
        }) { (completion) in
            guard completion else { return }
            self.balanceValueLabel.isHidden = !balanceShown
            self.balanceLabel.isHidden = !balanceShown
            self.showButton.isHidden = !balanceShown
            self.hideButton.isHidden = balanceShown
//            self.delegate?.recentBeneficiaryViewDidAnimate(self)
        }
    }
}

private extension HomeViewController {
   /* func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    } */

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

extension HomeViewController: ProgressBarDidTapped {
    func progressViewDidTapped(viewForMonth month: String) {
       // viewModel.inputs.progressViewTappedObserver.onNext(())
    }
    
    func setDate(date: NSMutableAttributedString) {
       // todaysBalanceTitleLabel.attributedText = date
        balanceDateLabel.attributedText = date
    }
    
    func setBalance(balance: String) {
        var finalBalance: Balance {
            return Balance(balance: balance, currencyCode: "PKR", currencyDecimals: "2", accountNumber: "")
        }
        let text = finalBalance.formattedBalance(showCurrencyCode: false, shortFormat: true)
        let attributedString = NSMutableAttributedString(string: text)
        guard let decimal = text.components(separatedBy: ".").last else { return }
        attributedString.addAttribute(.font, value: UIFont.regular/*appFont(ofSize: 18, weigth: .regular, theme: .main) */, range: NSRange(location: text.count-decimal.count, length: decimal.count))
       // ammount.attributedText = attributedString
        balanceValueLabel.attributedText = attributedString
    }
}

extension Reactive where Base: HomeViewController {
    
    var date: Binder<NSMutableAttributedString> {
        return Binder(self.base) { home, date in
            home.setDate(date: date)
        }
    }
    
    var balance: Binder<String> {
        return Binder(self.base) { home, balance in
            home.setBalance(balance: balance)
        }
    }
    
  /*  var month: Binder<String> {
        return Binder(self.base) { toolbar,month in
            toolbar.month = month
        }
    }
    
    var shrink: Binder<Bool> {
        return Binder(self.base) { toolbar,shrink in
            toolbar.shrinkProgressView(shrink)
            toolbar.isProgressViewShrinked = shrink
        }
    }
    
    var monthData: Binder<(MonthData?, Int?)> {
        return Binder(self.base) { toolBar,monthData in
            if let monthlyAnalytics = monthData.0 {
                toolBar.progressView.isHidden = false
                toolBar.animateMonthlyAnalytics(monthData: monthlyAnalytics)
                toolBar.setupBarData(section: monthData.1 ?? 0)
            }
            else {
                toolBar.progressView.isHidden = true
            }
        }
    }
    
    var numberOfSections: Binder<Int?> {
        return Binder(self.base) { toolBar,section in
            if section ?? 0 > 9 {
                toolBar.sectionCount = 10
            }
            else {
                toolBar.sectionCount = section ?? 0
            }
        }
    }
    
    var categoryImage: Binder<String> {
        return Binder(self.base) { toolBar,url in
            toolBar.setupCategoryImage(url)
        }
    } */
}
