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

//    private lazy var toolBar: HomeBalanceToolbarUpdated = {
//        let toolBar = HomeBalanceToolbarUpdated()
//        toolBar.backgroundColor = .clear
//        toolBar.delegate = self
//        toolBar.translatesAutoresizingMaskIntoConstraints = false
//        return toolBar
//    }()

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
//        var res = DashboardWidgetsResponse.mock
//        res.iconPlaceholder = UIImage.init(named: "icon_add_card", in: .yapPakistan)
//        buttons.viewModel.inputs.widgetsDataObserver.onNext([res,res,res,res,res,res,res])
        
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
        
        setup()
      //  bindTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppearObserver.onNext(())
       // viewModel.inputs.viewAppearObserver.onNext(())
        updateParallaxHeaderProgress()
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
//        viewModel.inputs.refreshObserver.onNext(())
    }
    
//    private func render() {
//        self.profileImageView.layer.cornerRadius = 12
//        self.profileImageView.clipsToBounds = true
//    }
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
        addTransactionsViewController()
        bindViewModel()
    }
    
    private func setupViews() {
        
        balanceView.addSubviews([balanceLabel,balanceValueLabel,showButton,hideButton,balanceDateLabel,separtorView])
      //  containerView.addSubview(balanceView)
      /*  containerView.addSubview(tableView)
        view.addSubview(containerView)
        
        containerView.isHidden = true
        tableView.isHidden = true */
        
        view.addSubview(balanceView)
        view.addSubview(scrollView)

        scrollView.addSubview(transactionContainer)
     //   scrollView.addSubview(bottomContainerView)
        parallaxHeaderView.addSubview(headerStackView)
//        bottomContainerView.addSubview(timelineView)
//        bottomContainerView.addSubview(creditLimitView)
      
        
        parallaxHeaderView
            .width(with: .width, ofView: view)
            //.height(constant: scrollView.parallaxHeader.height)

        headerStackView
            .alignEdgesWithSuperview([.left, .right,.top])
        
        scrollView
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])
            .toBottomOf(balanceView)
        

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
        
        separtorView.alpha = 0
        
    /*    tableView.register(CreditLimitCell.self, forCellReuseIdentifier: CreditLimitCell.defaultIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0) */
        
      //  stack.addArrangedSubviews([balanceView, tableView])
        showButton.imageView?.contentMode = .scaleAspectFit
        showButton.setImage(UIImage.init(named: "icon_view_cell", in: .yapPakistan)?.asTemplate, for: .normal)
        hideButton.setImage(UIImage.init(named: "eye_close", in: .yapPakistan), for: .normal)
        hideButton.isHidden = true
        separtorView.alpha = 0
        separtorView.backgroundColor = .yellow
        balanceLabel.text = "PKR"
       // balanceValueLabel.text = "PKR 0.00"
        balanceDateLabel.text = "Today's balance"
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
           // .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: (searchBarButtonItem.button?.rx.tintColor)!)
            .bind({ UIColor($0.greyDark) }, to: [balanceDateLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [completeVerificationButton.rx.backgroundColor,showButton.rx.tintColor])
            .bind({ UIColor($0.primaryDark) }, to: [separtorView.rx.backgroundColor,balanceValueLabel.rx.textColor])
        
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        
//        containerView
//            .alignAllEdgesWithSuperview()
        transactionContainer
            .alignEdgesWithSuperview([.left, .top, .bottom])
            .width(with: .width, ofView: scrollView)
        
        balanceView
            .height(constant: 70)
            .alignEdgesWithSuperview([.left, .top, .right], constants: [0, 0, 0])
        
//        tableView
//            .toBottomOf(balanceView)
//            .alignEdgesWithSuperview([.left, .right,.bottom], constants: [0, 0,0])
        
//        balanceValueLabel
//            .alignEdgesWithSuperview([.left, .top, .right], constants: [24, 12, 24])
        
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
        
        balanceHeight = balanceValueLabel.heightAnchor.constraint(equalToConstant: 24) //balanceValueLabel.heightAnchor.constraint(equalToConstant: 24)
        balanceHeight.priority = .required
        balanceHeight.isActive = true
        
        
        balanceLabelHeight = balanceLabel.heightAnchor.constraint(equalToConstant: 24)
        balanceLabelHeight.priority = .required
        balanceLabelHeight.isActive = true
//        transactionContainer
//            .alignEdgesWithSuperview([.left, .top, .bottom])
//            .width(with: .width, ofView: scrollView)
        
      /*  bottomContainerView
            .alignEdgesWithSuperview([.left, .top, .bottom])
            .width(with: .width, ofView: scrollView)
        
        creditLimitView
            .alignEdgesWithSuperview([.left, .top,.right])
          //  .toBottomOf(timelineView,constant: 12)
          //  .height(constant: 42)
            .height(constant: 0)
        
        timelineView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(creditLimitView,constant: 12)
            .height(constant: 140) */
        
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
                self?.widgetViewHeightConstraints.constant = 0
                self?.widgetView.isHidden = true
            }
            else {
                self?.widgetViewHeightConstraints.constant = 115
                self?.widgetView.isHidden = false
            }
            self?.updateParallaxHeaderProgress()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.dashboardWidgets.bind(to: widgetView.rx.dashboardWidgets).disposed(by: disposeBag)
        
        widgetView.viewModel.selectedWidget.subscribe(onNext: {[weak self] in
            self?.viewModel.inputs.selectedWidgetObserver.onNext($0 ?? .unknown)
        }).disposed(by: disposeBag)
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
                stagesView.alignAllEdgesWithSuperview()
            } else {
                self.transactionContainer.subviews.filter { $0 is PaymentCardOnboardingStatusView }.first?.removeFromSuperview()
            }}, onCompleted: { [weak self] in
                guard let `self` = self else { return }
               // self.addTransactionsViewController()
        }).disposed(by: disposeBag)
        
       /* viewModel.outputs.resumeKYC.subscribe(onNext: { [weak self] vms in
            guard let `self` = self else { return }
            
            let view = DashboardTimelineView(theme: self.themeService, viewModel: vms.first!)
            
            self.transactionContainer.addSubview(view)
            view.alignAllEdgesWithSuperview()
            
            self.addTransactionsViewController()
          /*  if let stagesViewModel = stagesViewModel {
                self.transactionContainer.subviews.filter { $0 is Dashb }.forEach { $0.removeFromSuperview() }
                let stagesView = PaymentCardOnboardingStatusView(theme: self.themeService, viewModel: stagesViewModel)
                self.transactionContainer.addSubview(stagesView)
                stagesView.alignAllEdgesWithSuperview()
            } else {
                self.transactionContainer.subviews.filter { $0 is PaymentCardOnboardingStatusView }.first?.removeFromSuperview()
            }*/ }, onCompleted: { [weak self] in
                guard let `self` = self else { return }
//                self.addTransactionsViewController()
        }).disposed(by: disposeBag) */
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

//extension HomeViewController: ProgressBarDidTapped {
//    func progressViewDidTapped(viewForMonth month: String) {
//        viewModel.inputs.progressViewTappedObserver.onNext(())
//    }
//}
