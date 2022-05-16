//
//  CardAnalyticsViewController.swift
//  YAP
//
//  Created by Zain on 20/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

// import AppAnalytics
import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents
import RxDataSources
import MXParallaxHeader

class CardAnalyticsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var monthlyContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var monthly = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .primary, textStyle: .micro, alignment: .center)
    
    private lazy var weekly = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .primary, textStyle: .micro, alignment: .center)
    
    private lazy var monthlyWeeklyStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 16, arrangedSubviews: [monthlyContainerView])
    
    
    private lazy var monthlyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        button.addTarget(self, action: #selector(CardAnalyticsViewController.typeAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var weeklyButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(CardAnalyticsViewController.typeAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var monthLabel = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var amountLabel = UIFactory.makeLabel(font: .large, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .large, alignment: .center)
    
    private lazy var monthAmountStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 1, arrangedSubviews: [monthLabel, amountLabel])
    
    private lazy var backArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.sharedImage(named: "icon_backward")?.asTemplate, for: .normal)
        //button.tintColor = .greyDark
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nextArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_forward", in: .yapPakistan)?.asTemplate, for: .normal)
       // button.tintColor = .greyDark
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private lazy var amountHeaderLabel = UIFactory.makeLabel(font: .micro, alignment: .center, text: "Total spent") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro , alignment: .center, text: "Total spent")
    
    private lazy var navStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [backArrow, monthAmountStack, nextArrow])
    
    private lazy var pieChart: PieChart = {
        let view = PieChart()
        view.arcWidth = 22
        view.selectedArcWidth = 34
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var categoryTitle = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .white, textStyle: .micro, alignment: .center)
    private lazy var categoryAmount = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro, alignment: .center)
    private lazy var percentage = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var averageLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_analytics_display_text_category".localized, for: .normal)
        button.titleLabel?.font = .small
        //button.setTitleColor(.primaryDark, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var merchantButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_analytics_display_text_merchant".localized, for: .normal)
        button.titleLabel?.font = .small
       // button.setTitleColor(.primaryDark, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var selector: UIView = {
        let view = UIView()
       // view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
      //  view.backgroundColor = .greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var parallax: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.parallaxHeader.view = parallax
        tableView.parallaxHeader.height = 450
        tableView.parallaxHeader.minimumHeight = 325
        tableView.parallaxHeader.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var pieChartTop: NSLayoutConstraint!
    private var selectorX: NSLayoutConstraint!
    private var viewModel: CardAnalyticsViewModelType!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: CardAnalyticsViewModelType) {
        super.init(nibName: nil, bundle: nil)
        
        self.themeService = themeService
        self.viewModel = viewModel
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(of: .closeEmpty)
        navigationItem.title = "screen_card_analytics_display_text_title".localized
        
        setupViews()
        setupConstraints()
        setupSensitiveViews()
        bindViews()
        bindTableView()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        render()
    }
    
    // MARK: Actions
    
    override func onTapBackButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func typeAction(sender: UIButton) {
//        sender.tag==0 ? AppAnalytics.shared.logEvent(AnalyticsEvent.monthlyTapped()):AppAnalytics.shared.logEvent(AnalyticsEvent.weeklyTapped())
    }
}

// MARK: View setup

private extension CardAnalyticsViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        parallax.addSubview(monthlyWeeklyStack)
        monthlyContainerView.addSubview(monthly)
        monthlyContainerView.addSubview(monthlyButton)
        parallax.addSubview(amountHeaderLabel)
        parallax.addSubview(navStack)
        parallax.addSubview(pieChart)
        parallax.addSubview(averageLabel)
        parallax.addSubview(categoryButton)
        parallax.addSubview(merchantButton)
        parallax.addSubview(separator)
        parallax.addSubview(selector)
        pieChart.addSubview(icon)
        pieChart.addSubview(categoryTitle)
        pieChart.addSubview(categoryAmount)
        pieChart.addSubview(percentage)
        
        view.addSubview(tableView)
        
        tableView.register(AnalyticsCategoryCell.self, forCellReuseIdentifier: AnalyticsCategoryCell.defaultIdentifier)
        tableView.register(AnalyticsEmptyDataCell.self, forCellReuseIdentifier: AnalyticsEmptyDataCell.defaultIdentifier)
        
        averageLabel.isHidden = true
    }
    
    func setupConstraints() {
        
        tableView
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom])
        
        parallax
            .width(with: .width, ofView: tableView)
        
        monthlyWeeklyStack
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.top, constant: 11)
            .height(constant: 20)
        
        
        monthlyContainerView
            .width(constant: 80)
            .height(constant: 20)
        
        monthly
            .alignAllEdgesWithSuperview()
        
        weekly
            .alignAllEdgesWithSuperview()
        
        monthlyButton
            .alignAllEdgesWithSuperview()
        
        weeklyButton
            .alignAllEdgesWithSuperview()
        
        monthAmountStack
            .width(constant: 160)
        
        nextArrow
            .width(constant: 26)
            .height(constant: 26)
        
        backArrow
            .width(constant: 26)
            .height(constant: 26)
        
        amountHeaderLabel
            .toTopOf(monthAmountStack)
            .centerHorizontallyInSuperview()
        
        navStack
            .height(constant: 50)
            .toBottomOf(monthlyWeeklyStack, constant: 17)
            .centerHorizontallyInSuperview()
        
        pieChart
            .toBottomOf(navStack, constant: 17)
            .centerHorizontallyInSuperview()
            .width(constant: 220)
            .height(constant: 220)
        
        icon
            .alignEdgeWithSuperview(.top, constant: pieChart.selectedArcWidth + 20)
            .centerHorizontallyInSuperview()
            .width(constant: 30)
            .height(constant: 30)
        
        categoryTitle
            .toBottomOf(icon, constant: 8)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: pieChart.selectedArcWidth + 10)
        
        categoryAmount
            .toBottomOf(categoryTitle, constant: 4)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: pieChart.selectedArcWidth + 15)
        
        percentage
            .toBottomOf(categoryAmount, constant: 4)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: pieChart.selectedArcWidth + 10)
        
        averageLabel
            
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperview(.bottom, constant: 50)
            .height(constant: 15)
        
        categoryButton
            .alignEdgesWithSuperview([.left, .bottom])
            .height(constant: 35)
        
        merchantButton
            .toRightOf(categoryButton)
            .width(with: .width, ofView: categoryButton)
            .height(with: .height, ofView: categoryButton)
            .alignEdgesWithSuperview([.right, .bottom])
        
        separator
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .height(constant: 1)
        
        selector
            .alignEdgeWithSuperview(.bottom)
            .width(with: .width, ofView: categoryButton)
            .height(constant: 2)
        
        selectorX = selector.leadingAnchor.constraint(equalTo: parallax.leadingAnchor)
        selectorX.isActive = true
        
        pieChartTop = pieChart.topAnchor.constraint(equalTo: parallax.topAnchor, constant: 125)
        pieChartTop.isActive = true
        
        icon.clipsToBounds = true
        self.view.layoutAllSubviews()
    }
    
    func setupSensitiveViews() {
        // UIView.markSensitiveViews([amountLabel, categoryAmount])
    }
    
    func render() {
       // monthly.backgroundColor = UIColor.primary.withAlphaComponent(0.15)
        monthly.roundView()
    }
}

// MARK: Binding

private extension CardAnalyticsViewController {
    func bindViews() {
        viewModel.outputs.monthly.bind(to: monthly.rx.text).disposed(by: disposeBag)
        viewModel.outputs.weekly.bind(to: weekly.rx.text).disposed(by: disposeBag)
        viewModel.outputs.month.bind(to: monthLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.average.bind(to: averageLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.selectedTab.subscribe(onNext: { [weak self] in self?.selectorX.constant = $0 == 0 ? 0 : self?.selector.bounds.width ?? 0}).disposed(by: disposeBag)
        viewModel.outputs.nextEnabled.bind(to: nextArrow.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.backEnabled.bind(to: backArrow.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.pieChartData.bind(to: pieChart.rx.components).disposed(by: disposeBag)
        viewModel.outputs.userAllowedToInteract.bind(to: pieChart.rx.isUserInteractionEnabled).disposed(by: disposeBag)
        viewModel.outputs.selectedIndex.bind(to: pieChart.rx.selectedIndex).disposed(by: disposeBag)
        viewModel.outputs.selectedCategory.subscribe(onNext: { [weak self] in
            if $0 > self?.tableView.numberOfRows(inSection: 0) ?? 0 {
                self?.tableView.scrollToRow(at: IndexPath(row: $0, section: 0), at: .top, animated: true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.categoryColor.subscribe(onNext: { [weak self] in
            self?.categoryTitle.textColor = $0
            self?.icon.tintColor = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.categoryIcon
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] args in
            self?.icon.loadImage(with: args.0.0, placeholder: args.0.1, showsIndicator: false, completion: { (image, error, url) in
                if url != nil && args.1 == .category {
                    self?.icon.image = image?.withRenderingMode(.alwaysTemplate)
                }
            })
        }).disposed(by: disposeBag)
        
        viewModel.outputs.categoryTitle.bind(to: categoryTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.categoryAmount.bind(to: categoryAmount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.percentage.bind(to: percentage.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        
        Observable.merge(categoryButton.rx.tap.map { 0 }, merchantButton.rx.tap.map { 1 }).bind(to: viewModel.inputs.selectedTabObserver).disposed(by: disposeBag)

        backArrow.rx.tap
            .do(onNext: {[weak self] _ in
                self?.viewModel.inputs.selectedTabObserver.onNext(0)
                self?.viewModel.inputs.selectedCategoryObserver.onNext(0)
                self?.pieChart.rx.selectedIndex.onNext(0)
            }).filter { [unowned self] in return self.backArrow.alpha > 0.6 }
            .bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        
        nextArrow.rx.tap
            .do(onNext: {[weak self] _ in
                self?.viewModel.inputs.selectedTabObserver.onNext(0)
                self?.viewModel.inputs.selectedCategoryObserver.onNext(0)
                self?.pieChart.rx.selectedIndex.onNext(0)
            }).filter { [unowned self] in return self.nextArrow.alpha > 0.6  }
            .bind(to: viewModel.inputs.nextObserver).disposed(by: disposeBag)
        
        pieChart.rx.selectedIndex.bind(to: viewModel.inputs.selectedCategoryObserver).disposed(by: disposeBag)
        
        viewModel.outputs.mode.subscribe(onNext: { [unowned self] (mode) in
            self.icon.contentMode = mode
        }).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, indexPath, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            cell.setIndexPath(indexPath)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).filter { $0 is AnalyticsCategoryCellViewModel }.map {
            ($0 as! AnalyticsCategoryCellViewModel).position
        }.bind(to: viewModel.inputs.selectedCategoryObserver).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self).filter { $0 is AnalyticsCategoryCellViewModel }.map {
            (($0 as! AnalyticsCategoryCellViewModel).data, ($0 as! AnalyticsCategoryCellViewModel).analyticsType, ($0 as! AnalyticsCategoryCellViewModel).analyticsColor)
        }.bind(to: viewModel.inputs.selectedAnalyticDataObeserver).disposed(by: disposeBag)
    }
}

// MARK: Parallex header delegate

extension CardAnalyticsViewController: MXParallaxHeaderDelegate {
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        let progress = parallaxHeader.progress > 1 ? 1 : parallaxHeader.progress
        monthly.alpha = progress
        monthLabel.alpha = progress
        amountLabel.alpha = progress
        nextArrow.alpha = progress
        backArrow.alpha = progress
        amountHeaderLabel.alpha = progress
        pieChartTop.constant = 30 + (95 * progress)
    }
}
