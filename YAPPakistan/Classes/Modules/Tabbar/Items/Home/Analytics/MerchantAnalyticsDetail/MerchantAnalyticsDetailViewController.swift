//
//  MerchantAnalyticsDetailViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 20/05/2022.
//

import UIKit
import YAPCore
import YAPComponents
import MXParallaxHeader
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme


class MerchantAnalyticsDetailViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: nil)
        return imageView
    }()
    
    private lazy var monthLabel = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var amountLabel = UIFactory.makeLabel(font: .title2, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title2, alignment: .center)
    
    private lazy var monthAmountStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [monthLabel, amountLabel])
    
    private lazy var iconMonthAmountStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 16, arrangedSubviews: [iconContainer, monthAmountStack])
    
    private lazy var transactionsTitle = UIFactory.makeLabel(font: .regular, alignment: .left) //UILabelFactory.createUILabel(with: .black, textStyle: .regular, alignment: .left)
    
    private lazy var statsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var parallax: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var monthlySpendView: AnalyticsStatsView = {
        let view = AnalyticsStatsView(theme: themeService)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nameLabel.text = "monthly spend"
        return view
    }()
    
    private lazy var vsLastMonthView: AnalyticsStatsView = {
        let view = AnalyticsStatsView(theme: themeService)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nameLabel.text = "vs. last month"
        return view
    }()
    
    private lazy var averageSpendView: AnalyticsStatsView = {
        let view = AnalyticsStatsView(theme: themeService)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nameLabel.text = "average spend"
        return view
    }()
    
    private lazy var separator1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(themeService.attrs.greyLight)
        return view
    }()
    
    private lazy var separator2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(themeService.attrs.greyLight)
        return view
    }()
    
    private lazy var transactionsSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 0.11)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.parallaxHeader.view = parallax
        tableView.parallaxHeader.height = 326
        tableView.parallaxHeader.minimumHeight = 165
        tableView.parallaxHeader.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: MerchantAnalyticsDetailViewModelType!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var iconWidthConstaint: NSLayoutConstraint?
    private var iconHeightConstraint: NSLayoutConstraint?
    private var backButton: UIButton?
    
    // MARK: Initialization
    
//    init(viewModel: MerchantAnalyticsDetailViewModelType) {
//        super.init(nibName: nil, bundle: nil)
//        self.viewModel = viewModel
//    }
    
    init(themeService: ThemeService<AppTheme>, viewModel: MerchantAnalyticsDetailViewModelType) {
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
        
        backButton = addBackButton(of: .backEmpty)
        navigationItem.title = "screen_card_analytics_display_text_title".localized
        
        setupViews()
        setupConstraints()
        setupTheme()
        setupSensitiveViews()
        bindViews()
        bindTableView()
        
        viewModel.outputs.title.subscribe(onNext: { [weak self] (title) in
            self?.title = title
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.fetchDataObserver.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
    
    // MARK: Actions
    
    override func onTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: View setup

private extension MerchantAnalyticsDetailViewController {
    func setupViews() {
        view.backgroundColor = .white
        iconContainer.addSubview(icon)
        parallax.addSubview(iconMonthAmountStack)
        parallax.addSubview(transactionsTitle)
        parallax.addSubview(statsContainerView)
        parallax.addSubview(transactionsSeparator)
        statsContainerView.addSubview(monthlySpendView)
        statsContainerView.addSubview(vsLastMonthView)
        statsContainerView.addSubview(averageSpendView)
        statsContainerView.addSubview(separator1)
        statsContainerView.addSubview(separator2)
        view.addSubview(tableView)
        view.addSubview(overlayView)
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        tableView
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom])
        
        parallax
            .width(with: .width, ofView: tableView)
        
        iconMonthAmountStack
            .alignEdgesWithSuperview([.left, .right], constants: [50, 50])
            .alignEdgeWithSuperview(.safeAreaTop, constant: 20)
        
        iconContainer
            .width(constant: 64)
            .height(constant: 64)
        
        statsContainerView
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(iconMonthAmountStack, constant: 24)
            .height(constant: 90)
        
        monthlySpendView
            .alignEdgesWithSuperview([.top, .left, .bottom])
        
        separator1
            .width(constant: 1)
            .toRightOf(monthlySpendView)
            .alignEdgesWithSuperview([.top, .bottom], constants: [17, 17])
        
        vsLastMonthView
            .alignEdgesWithSuperview([.top, .bottom])
            .toRightOf(separator1)
        
        separator2
            .width(constant: 1)
            .toRightOf(vsLastMonthView)
            .alignEdgesWithSuperview([.top, .bottom], constants: [17, 17])
        
        averageSpendView
            .alignEdgesWithSuperview([.top, .bottom, .right])
            .toRightOf(separator2)
        
        monthlySpendView.widthAnchor.constraint(equalTo: vsLastMonthView.widthAnchor, multiplier: 1.0).isActive = true
        
        monthlySpendView.widthAnchor.constraint(equalTo: averageSpendView.widthAnchor, multiplier: 1.0).isActive = true
        
        iconContainer.layer.cornerRadius = 32
        icon.clipsToBounds = true
        
        overlayView.alignAllEdgesWithSuperview()
        
        self.iconWidthConstaint = icon.widthAnchor.constraint(equalToConstant: 64)
        self.iconHeightConstraint = icon.heightAnchor.constraint(equalToConstant: 64)
        guard let iconWidth = self.iconWidthConstaint, let iconHeight = self.iconHeightConstraint else { return }
        NSLayoutConstraint.activate([iconWidth, iconHeight])
        
        icon
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark       ) }, to: [monthLabel.rx.textColor])
//            .bind({ UIColor($0.primary        ) }, to: [termsAndCondtionsButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primaryDark    ) }, to: [amountLabel.rx.textColor])
//            .bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
            .disposed(by: disposeBag)

        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [backButton!.rx.tintColor])
            .disposed(by: disposeBag)
    }
    
    func setupSensitiveViews() {
       // UIView.markSensitiveViews([amountLabel])
    }
    
    func render() {
        iconContainer.layer.cornerRadius = 32
        iconContainer.layer.masksToBounds = true
    }
    
    func setupIconConstraint(type: AnalyticsDataType = .merchant) {
        if type == .merchant {
            self.iconWidthConstaint?.constant = 64
            self.iconHeightConstraint?.constant = 64
            icon.layer.cornerRadius = 32
        }
        else {
            self.iconWidthConstaint?.constant = 40
            self.iconHeightConstraint?.constant = 40
            icon.layer.cornerRadius = 0
        }
    }
}

// MARK: Binding

private extension MerchantAnalyticsDetailViewController {
    func bindViews() {
        viewModel.outputs.color.subscribe(onNext: { [weak self] in
            //            self?.title.textColor = $0
            self?.icon.tintColor = $0.0
            if $0.1 == .category {
                self?.iconContainer.backgroundColor = $0.0.withAlphaComponent(0.15)
            }
        }).disposed(by: disposeBag)
        viewModel.outputs.month.bind(to: monthLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.categoryIcon.subscribe(onNext: {[weak self] args in
            self?.icon.loadImage(with: args.0.0, placeholder: args.0.1, showsIndicator: false, completion: { (image, error, url) in
                if url != nil && args.1 == .category {
                    self?.icon.image = image?.withRenderingMode(.alwaysTemplate)
                } else {
                    self?.icon.image = image?.withRenderingMode(.alwaysOriginal)
                }
            })
        }).disposed(by: disposeBag)
        viewModel.outputs.showError.subscribe(onNext: { [weak self] errorMessage in
            self?.showAlert(title: "", message: errorMessage, defaultButtonTitle:  "common_button_ok".localized, secondayButtonTitle: nil, defaultButtonHandler: { [weak self] _ in
                self?.onTapBackButton()
                }, secondaryButtonHandler: nil, completion: nil)
        }).disposed(by: disposeBag)
        viewModel.outputs.transactionsTitle.bind(to: transactionsTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.monthlySpend.bind(to: monthlySpendView.rx.value).disposed(by: disposeBag)
        viewModel.outputs.vsLastMonth.bind(to: vsLastMonthView.rx.value).disposed(by: disposeBag)
        viewModel.outputs.averageSpend.bind(to: averageSpendView.rx.value).disposed(by: disposeBag)
        viewModel.outputs.iconImageMode.subscribe(onNext: { [weak self] (mode) in
            self?.icon.contentMode = mode
        }).disposed(by: disposeBag)
        viewModel.outputs.hideOverlayView.bind(to: overlayView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.hideStats.subscribe(onNext: { [unowned self] (hide) in
            self.statsContainerView.isHidden = hide
            if hide {
                self.tableView.parallaxHeader.height = 195
                self.transactionsTitle
                    .toBottomOf(self.iconMonthAmountStack, constant: 15)
                    .alignEdgeWithSuperview(.left, constant: 26)
            } else {
                self.transactionsTitle
                    .toBottomOf(self.statsContainerView, constant: 30)
                    .alignEdgeWithSuperview(.left, constant: 26)
            }
            self.transactionsSeparator
                .alignEdgesWithSuperview([.left, .right])
                .toBottomOf(self.transactionsTitle, constant: 14)
                .height(constant: 1)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.dataType.subscribe(onNext: { [weak self] type in
            self?.setupIconConstraint(type: type)
        }).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, indexPath, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            cell.setIndexPath(indexPath)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}

// MARK: Parallex header delegate

extension MerchantAnalyticsDetailViewController: MXParallaxHeaderDelegate {
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        let progress = parallaxHeader.progress > 1 ? 1 : parallaxHeader.progress
        transactionsTitle.alpha = progress
        statsContainerView.alpha = progress
    }
}

