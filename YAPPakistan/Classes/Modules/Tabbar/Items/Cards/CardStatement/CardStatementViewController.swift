//
//  CardStatementViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 28/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxDataSources
import RxTheme

class CardStatementViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var yearDecrementButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_backward", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var yearIncrementButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_forward", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var yearLabel: UILabel = UIFactory.makeLabel(font: .large, alignment: .center)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //!!!: Quick Statement Views
    
    //Last Financial Year
    private lazy var lastFinYearView = UIFactory.makeView()
    
    private lazy var LFYIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_statement", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var LFYStatementTitle: UILabel = UIFactory.makeLabel(font: .regular, text: "Last financial year")
    private lazy var LFYStatementDateText: UILabel = UIFactory.makeLabel(font: .micro)
    
    private lazy var LFYViewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_statements_display_text_view".localized, for: .normal)
        button.titleLabel?.font = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Year to Date
    private lazy var yearToDateView = UIFactory.makeView()
    
    private lazy var YTDIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_statement", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var YTDStatementTitle: UILabel = UIFactory.makeLabel(font: .regular, text: "Year to Date")
    private lazy var YTDStatementDateText: UILabel = UIFactory.makeLabel(font: .micro)
    
    private lazy var YTDViewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_statements_display_text_view".localized, for: .normal)
        button.titleLabel?.font = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Custom Date
    private lazy var customDateView = UIFactory.makeView()
    
    private lazy var CDIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_statement", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var CDStatementTitle: UILabel = UIFactory.makeLabel(font: .regular, text: "Choose a custom date range")
    private lazy var CDStatementDateText: UILabel = UIFactory.makeLabel(font: .micro, numberOfLines: 0)
    
    private lazy var CDViewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_card_statements_display_text_view".localized, for: .normal)
        button.titleLabel?.font = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var quickStatementStack = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 10.0)
    
    private lazy var quickStatementSeparator = UIFactory.makeView()
    
    private var backButton: UIButton!
    
    // MARK: Properties
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    private var viewModel: CardStatementViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: CardStatementViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = addBackButton(of: .backEmpty)
        
        setupViews()
        setupConstraints()
        bindViews()
        setupTheme()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppearObserver.onNext(())
    }
    
}

// MARK: View setup

private extension CardStatementViewController {
    func setupViews() {
        
        lastFinYearView.addSubview(LFYIcon)
        lastFinYearView.addSubview(LFYStatementTitle)
        lastFinYearView.addSubview(LFYStatementDateText)
        lastFinYearView.addSubview(LFYViewButton)
        
        yearToDateView.addSubview(YTDIcon)
        yearToDateView.addSubview(YTDStatementTitle)
        yearToDateView.addSubview(YTDStatementDateText)
        yearToDateView.addSubview(YTDViewButton)
        
        customDateView.addSubview(CDIcon)
        customDateView.addSubview(CDStatementTitle)
        customDateView.addSubview(CDStatementDateText)
        customDateView.addSubview(CDViewButton)
        
        quickStatementStack.addArrangedSubview(lastFinYearView)
        quickStatementStack.addArrangedSubview(yearToDateView)
        quickStatementStack.addArrangedSubview(customDateView)
        
        view.addSubview(quickStatementStack)
        view.addSubview(quickStatementSeparator)
        
        view.backgroundColor = .white
        view.addSubview(yearDecrementButton)
        view.addSubview(yearIncrementButton)
        view.addSubview(yearLabel)
        view.addSubview(tableView)
        
        tableView.register(StatementMonthTableViewCell.self, forCellReuseIdentifier: StatementMonthTableViewCell.defaultIdentifier)
        tableView.register(NoStatementCell.self, forCellReuseIdentifier: NoStatementCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        yearLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
            .centerHorizontallyInSuperview()
            .width(constant: 150)
            .height(constant: 30)
        
        yearDecrementButton
            .alignEdge(.centerY, withView: yearLabel)
            .toLeftOf(yearLabel)
            .width(constant: 30)
            .height(constant: 30)
        
        yearIncrementButton
            .alignEdge(.centerY, withView: yearLabel)
            .toRightOf(yearLabel)
            .width(constant: 30)
            .height(constant: 30)
        
        quickStatementStack
            .toBottomOf(yearLabel, constant: 31)
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
        
        //Last Financial Year
        LFYIcon
            .alignEdgesWithSuperview([.left, .top], constants: [0, 0])
            .height(constant: 25)
            .width(constant: 25)

        LFYStatementTitle
            .alignEdgeWithSuperview(.top)
            .toRightOf(LFYIcon, constant: 15)
            .toLeftOf(LFYViewButton, constant: 15)

        LFYStatementDateText
            .toBottomOf(LFYStatementTitle, constant: 2.0)
            .toRightOf(LFYIcon, constant: 15)
            .toLeftOf(LFYViewButton, constant: 15)
            .alignEdgeWithSuperview(.bottom)
            .height(constant: 18)

        LFYViewButton
            .alignEdgesWithSuperview([.right, .top], constants:[0, 0])
            .width(constant: 45)
            .height(constant: 30)

        //Year to Date
        YTDIcon
            .alignEdgesWithSuperview([.left, .top], constants: [0, 0])
            .height(constant: 25)
            .width(constant: 25)

        YTDStatementTitle
            .alignEdgeWithSuperview(.top)
            .toRightOf(YTDIcon, constant: 15)
            .toLeftOf(YTDViewButton, constant: 15)

        YTDStatementDateText
            .toBottomOf(YTDStatementTitle, constant: 2.0)
            .toRightOf(YTDIcon, constant: 15)
            .toLeftOf(YTDViewButton, constant: 15)
            .alignEdgeWithSuperview(.bottom)
            .height(constant: 18)

        YTDViewButton
            .alignEdgesWithSuperview([.right, .top], constants:[0, 0])
            .width(constant: 45)
            .height(constant: 30)
        
        //Custom Date
        CDIcon
            .alignEdgesWithSuperview([.left, .top], constants: [0, 0])
            .height(constant: 25)
            .width(constant: 25)

        CDStatementTitle
            .alignEdgeWithSuperview(.top)
            .toRightOf(CDIcon, constant: 15)
            .toLeftOf(CDViewButton, constant: 15)

        CDStatementDateText
            .toBottomOf(CDStatementTitle, constant: 2.0)
            .toRightOf(CDIcon, constant: 15)
            .toLeftOf(CDViewButton, constant: 15)
            .alignEdgeWithSuperview(.bottom)

        CDViewButton
            .alignEdgesWithSuperview([.right, .top], constants:[0, 0])
            .width(constant: 45)
            .height(constant: 30)
        
        quickStatementSeparator
            .toBottomOf(quickStatementStack, constant: 22)
            .height(constant: 1.0)
            .alignEdgesWithSuperview([.left, .right], constants: [28, 28])
        
        tableView
            .toBottomOf(quickStatementSeparator)
            .alignEdgesWithSuperview([.left, .right])
            .alignEdgeWithSuperviewSafeArea(.bottom)
            .toBottomOf(quickStatementSeparator, constant: 19)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: yearDecrementButton.rx.tintColor)
            .bind({ UIColor($0.greyDark) }, to: yearIncrementButton.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: yearLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
        
            .bind({ UIColor($0.greyDark) }, to: LFYIcon.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: LFYStatementTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: LFYStatementDateText.rx.textColor)
            .bind({ UIColor($0.primary) }, to: LFYViewButton.rx.titleColor(for: .normal))
        
            .bind({ UIColor($0.greyDark) }, to: YTDIcon.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: YTDStatementTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: YTDStatementDateText.rx.textColor)
            .bind({ UIColor($0.primary) }, to: YTDViewButton.rx.titleColor(for: .normal))
        
            .bind({ UIColor($0.greyDark) }, to: CDIcon.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: CDStatementTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: CDStatementDateText.rx.textColor)
            .bind({ UIColor($0.primary) }, to: CDViewButton.rx.titleColor(for: .normal))
        
            .bind({ UIColor($0.separatorColor).withAlphaComponent(0.10) }, to: quickStatementSeparator.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}

// MARK: Binding

private extension CardStatementViewController {
    
    func bindViews() {
        
        viewModel.outputs.year.bind(to: yearLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.decrementEnabled
            .do(onNext: { [unowned self] in self.yearDecrementButton.tintColor = $0 ? UIColor(self.themeService.attrs.greyDark) : UIColor(self.themeService.attrs.grey)})
            .bind(to: yearDecrementButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.incrementEnabled
            .do(onNext: { [unowned self] in self.yearIncrementButton.tintColor = $0 ? UIColor(self.themeService.attrs.greyDark) : UIColor(self.themeService.attrs.grey)})
            .bind(to: yearIncrementButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.title.unwrap().bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
                
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        yearDecrementButton.rx.tap.bind(to: viewModel.inputs.decrementYearObserver).disposed(by: disposeBag)
        yearIncrementButton.rx.tap.bind(to: viewModel.inputs.incrementYearObserver).disposed(by: disposeBag)
                
        viewModel.outputs.lastFinYearDescription.bind(to: LFYStatementDateText.rx.text).disposed(by: disposeBag)
        viewModel.outputs.yearToDateDescription.bind(to: YTDStatementDateText.rx.text).disposed(by: disposeBag)
        viewModel.outputs.customDateDescription.bind(to: CDStatementDateText.rx.text).disposed(by: disposeBag)
        
        CDViewButton.rx.tap.bind(to: viewModel.inputs.customDateObserver).disposed(by: disposeBag)
        LFYViewButton.rx.tap.bind(to: viewModel.inputs.lastFinYearObserver).disposed(by: disposeBag)
        YTDViewButton.rx.tap.bind(to: viewModel.inputs.yearToDateObserver).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        dataSource.titleForHeaderInSection = { [weak self] dataSource, index in
            let yearRelay = BehaviorRelay<String?>(value: "")
            self?.viewModel.outputs.year.bind(to: yearRelay).disposed(by: self!.disposeBag)
            let yearString = yearRelay.value
            return "Available \(yearString ?? "") statements"
        }
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}

extension CardStatementViewController: UIScrollViewDelegate, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(self.themeService.attrs.greyDark)
    }
    
}


