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

class MonthCollectionViewCellViewModel {
    
    let month: String
    let year: String
    let isEnable: Bool
    let isShowYear: Bool
    let date: Date
    
    init(date: Date, isFirstItem: Bool, isLastItem: Bool) {
        self.date = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        year = dateFormatter.string(from: date)
        isEnable = date.timeIntervalSince1970 <= Date().timeIntervalSince1970
        isShowYear = isFirstItem || isLastItem
    }
}

class MonthCollectionViewCell: RxUICollectionViewCell {
    
    // MARK: - Views
    lazy var title: UILabel = {
        let label = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var year: UILabel = {
        let label = UIFactory.makeLabel(font: .nano, alignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel: MonthCollectionViewCellViewModel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.contentView.addSub(views: [title,year])
        
        title.alignEdgesWithSuperview([.left, .top, .right])
        year.alignEdges([.left, .right], withView: contentView)
        year.alignEdge(.bottom, withView: contentView, constant: 6)
    }
    
    // MARK: - Selection
    func set(theme: ThemeService<AppTheme>, isSelected: Bool) {
        self.title.textColor = isSelected ? UIColor(theme.attrs.primaryDark) : UIColor(theme.attrs.greyDark)
        self.year.textColor = UIColor(theme.attrs.greyDark)
    }
    
    override func configure(with viewModel: Any, theme : ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? MonthCollectionViewCellViewModel else {return}
        themeService = theme
        self.viewModel = viewModel
        self.title.text = viewModel.month
        self.year.text = viewModel.year
        self.year.textColor = UIColor(theme.attrs.greyDark)
    }
    
    func updateSelection(isSelected: Bool) {
        if isSelected || viewModel?.isShowYear ?? true {
            self.year.isHidden = false
        }else {
            self.year.isHidden = true
        }
        self.title.textColor = isSelected ? UIColor(themeService.attrs.primaryDark) : UIColor(themeService.attrs.greyDark)
    }
}

class CardAnalyticsViewController: UIViewController {
    
    // MARK: Views
    private lazy var monthsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.itemSize = .init(width: 32, height: 38)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 40
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 28, bottom: 0, right: 28)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: MonthCollectionViewCell.defaultIdentifier)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    private lazy var monthsSelectionView = UIView(frame: .init(x: 0, y: 35, width: 34, height: 3))
    
//    private lazy var monthlyContainerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
//    private lazy var monthly = UIFactory.makeLabel(font: .micro, alignment: .center)
    //UILabelFactory.createUILabel(with: .primary, textStyle: .micro, alignment: .center)
    
//    private lazy var weekly = UIFactory.makeLabel(font: .micro, alignment: .center)
    //UILabelFactory.createUILabel(with: .primary, textStyle: .micro, alignment: .center)
    
//    private lazy var monthlyWeeklyStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 16, arrangedSubviews: [monthlyContainerView])
    
    
//    private lazy var monthlyButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.tag = 0
//        button.addTarget(self, action: #selector(CardAnalyticsViewController.typeAction(sender:)), for: .touchUpInside)
//        return button
//    }()
    
//    private lazy var weeklyButton: UIButton = {
//        let button = UIButton()
//        button.tag = 1
//        button.backgroundColor = .purple
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(CardAnalyticsViewController.typeAction(sender:)), for: .touchUpInside)
//        return button
//    }()
    
    
//    private lazy var monthLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var amountLabel = UIFactory.makeLabel(font: .large, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .large, alignment: .center)
    
    private lazy var monthAmountStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 1, arrangedSubviews: [amountLabel])
    
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
    private var selectedMonth: IndexPath? /*{
        didSet {
            if let oldValue = oldValue {
                (monthsCollectionView.cellForItem(at: oldValue) as? MonthCollectionViewCell)?.set(theme: themeService, isSelected: oldValue == selectedMonth)
            }
            if let newValue = selectedMonth {
                (monthsCollectionView.cellForItem(at: newValue) as? MonthCollectionViewCell)?.set(theme: themeService, isSelected: true)
            }
        }
    }*/
    
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
        
        _ = addBackButton(of: .closeEmpty)
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
        navStack.backgroundColor = .yellow
        themeService.rx.bind({ UIColor($0.primary) }, to: monthsSelectionView.rx.backgroundColor)
        
        monthsCollectionView.addSubview(monthsSelectionView)
        parallax.addSubview(monthsCollectionView)
        
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        parallax.addSubview(separator)
        separator.alignEdgesWithSuperview([.left, .right])
        separator.toBottomOf(monthsCollectionView)
        separator.height(constant: 1)
        themeService.rx.bind({ UIColor($0.greyExtraLight) }, to: separator.rx.backgroundColor)
        
//        monthlyContainerView.addSubview(monthly)
//        monthlyContainerView.addSubview(monthlyButton)
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
        
        monthsCollectionView.alignEdgesWithSuperview([.left, .top, .right])
        monthsCollectionView.toTopOf(parallax, constant: 16)
        monthsCollectionView.height(constant: 38)
        
        /*
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
            .alignAllEdgesWithSuperview()*/
        
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
//            .toBottomOf(monthlyWeeklyStack, constant: 17)
            .toBottomOf(monthsCollectionView, constant: 17)
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
//        monthly.roundView()
    }
}

// MARK: Binding

private extension CardAnalyticsViewController {
    func bindViews() {
//        viewModel.outputs.monthly.bind(to: monthly.rx.text).disposed(by: disposeBag)
//        viewModel.outputs.weekly.bind(to: weekly.rx.text).disposed(by: disposeBag)
//        viewModel.outputs.month.bind(to: monthLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.average.bind(to: averageLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.selectedTab.subscribe(onNext: { [weak self] in self?.selectorX.constant = $0 == 0 ? 0 : self?.selector.bounds.width ?? 0}).disposed(by: disposeBag)
//        viewModel.outputs.nextEnabled.bind(to: nextArrow.rx.isEnabled).disposed(by: disposeBag)
//        viewModel.outputs.backEnabled.bind(to: backArrow.rx.isEnabled).disposed(by: disposeBag)
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

//        backArrow.rx.tap
//            .do(onNext: {[weak self] _ in
//                self?.viewModel.inputs.selectedTabObserver.onNext(0)
//                self?.viewModel.inputs.selectedCategoryObserver.onNext(0)
//                self?.pieChart.rx.selectedIndex.onNext(0)
//            }).filter { [unowned self] in return self.backArrow.alpha > 0.6 }
//            .bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
//
//        nextArrow.rx.tap
//            .do(onNext: {[weak self] _ in
//                self?.viewModel.inputs.selectedTabObserver.onNext(0)
//                self?.viewModel.inputs.selectedCategoryObserver.onNext(0)
//                self?.pieChart.rx.selectedIndex.onNext(0)
//            }).filter { [unowned self] in return self.nextArrow.alpha > 0.6  }
//            .bind(to: viewModel.inputs.nextObserver).disposed(by: disposeBag)
        
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
        
        // months list
    viewModel.outputs.months.bind(to: monthsCollectionView.rx.items(cellIdentifier: MonthCollectionViewCell.defaultIdentifier, cellType: MonthCollectionViewCell.self)) { [unowned self] row,model,cell in
            cell.configure(with: model, theme: self.themeService)
            cell.updateSelection(isSelected: self.selectedMonth?.row == row)
        if self.selectedMonth?.row == row {
            self.monthsSelectionView.center = .init(x: cell.center.x, y: self.monthsSelectionView.center.y)
        }
        }.disposed(by: disposeBag)
        
        viewModel.outputs.selectedDate.take(2).withLatestFrom(viewModel.outputs.months) { date, list -> Int? in
            let comp = Calendar.current.dateComponents([.month, .year], from: date)
            
            for (index, item) in list.enumerated() {
                let current = Calendar.current.dateComponents([.month, .year], from: item.date)
                if current.month! == comp.month! && current.year! == comp.year! {
                    return index
                }
            }
            return nil
        }.compactMap{$0}.subscribe(onNext: { [weak self] (result) in
            self?.selectedMonth = IndexPath(item: result, section: 0)
            self?.monthsCollectionView.reloadData()
        }).disposed(by: disposeBag)
        
        monthsCollectionView.rx.itemSelected.do (onNext:{ [weak self] index in
            guard let cell = self?.monthsCollectionView.cellForItem(at: index) as? MonthCollectionViewCell else {return}
            //            guard cell.viewModel?.isEnable ?? true else {return}
            
            self?.selectedMonth = index
            self?.monthsCollectionView.reloadData()
            if let date = cell.viewModel?.date {
                self?.viewModel.inputs.didSelectDate.onNext(date)
            }
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else {return}
                self.monthsSelectionView.center = .init(x: cell.center.x, y: self.monthsSelectionView.center.y)
            }
        }).subscribe { _ in }.disposed(by: disposeBag)

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
//        monthly.alpha = progress
//        monthLabel.alpha = progress
        amountLabel.alpha = progress
        nextArrow.alpha = progress
        backArrow.alpha = progress
        amountHeaderLabel.alpha = progress
        pieChartTop.constant = 30 + (95 * progress)
    }
}
