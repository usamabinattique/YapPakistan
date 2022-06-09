//
//  TransactionsViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import YAPComponents
import RxTheme

class TransactionsViewController: UIViewController {

    // MARK: - Init
    init(viewModel: TransactionsViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Views
   // var tableView: UITableView = UIFactory.makeTableView(allowsSelection: false)
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
       // tableView.backgroundColor = .yellow
        return tableView
    }()
    
    private lazy var nothingLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, text: "screen_home_display_text_nothing_to_report".localized)
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.isHidden = true
        placeholderImageView.isHidden = true
        view.addSubview(placeholderImageView)
        view.addSubview(nothingLabel)
        return view
    }()
    
    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "image_empty_transaction", in: .yapPakistan, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var filterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
     private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical,
     alignment: .fill, distribution: .fill, spacing: 0, arrangedSubviews: [filterView, tableView])
    
    lazy var filterCount: PaddedLabel = {
        let label = PaddedLabel()
        label.textAlignment = .center
        label.font = .micro
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var transactionLabel: UILabel = UIFactory.makeLabel(font: .regular, text:  "common_display_text_transactions".localized)
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        return activityIndicator
    }()

    lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("screen_home_button_filter".localized, for: .normal)
        button.setImage(UIImage(named: "icon_filter_primary_dark", in: .yapPakistan)?.asTemplate, for: .normal)
        button.titleLabel?.font = .regular
        return button
    }()

    lazy var filterViewSeprator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var noTransFoundLabel = UIFactory.makeLabel(font: .large,
                                                        alignment: .center,
                                                        numberOfLines: 1,
                                                        lineBreakMode: .byWordWrapping)

    // MARK: - Properties
    let viewModel: TransactionsViewModelType
    let themeService: ThemeService<AppTheme>
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>>!
    let disposeBag: DisposeBag
    var lastVelocityYSign = 0

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        setup()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewAppearedObsever.onNext(())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        filterCount.clipsToBounds = true
        filterCount.layer.cornerRadius = 12.5
    }
}

// MARK: - Setup
fileprivate extension TransactionsViewController {
    func setup() {
        setupViews()
        themeSetup()
        setupConstraints()
    }

    func setupViews() {
//        view.addSubview(filterView)
//        view.addSubview(tableView)
        view.addSubview(placeholderView)
         view.addSubview(stackView)
        
        tableView.tableFooterView = UIView()

        tableView.showsVerticalScrollIndicator = false
        tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.defaultIdentifier)
        tableView.register(TransactionHeaderTableViewCell.self, forCellReuseIdentifier: TransactionHeaderTableViewCell.defaultIdentifier)
        tableView.register(BottomLoadingTableViewCell.self, forCellReuseIdentifier: BottomLoadingTableViewCell.defaultIdentifier)
        tableView.register(WelcomeToYapCell.self, forCellReuseIdentifier: WelcomeToYapCell.defaultIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)

        filterView.addSubview(transactionLabel)
        filterView.addSubview(filterButton)
        filterView.addSubview(filterViewSeprator)
        filterView.addSubview(filterCount)
        filterView.addSubview(activityIndicator)
        
        view.addSubview(noTransFoundLabel)
    }
    func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [nothingLabel.rx.textColor])
            .bind({ UIColor($0.primary).withAlphaComponent(0.17) }, to: [filterCount.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [filterCount.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [transactionLabel.rx.textColor, noTransFoundLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [filterButton.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [filterButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.grey) }, to: [filterButton.rx.titleColor(for: .disabled)])
            .bind({ UIColor($0.greyDark).withAlphaComponent(0.11) }, to: [filterViewSeprator.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        filterView
            .alignEdgesWithSuperview([.left, .right, .top])
        tableView
            .toBottomOf(filterView)
            .alignEdgesWithSuperview([.left, .right, .bottom])

        transactionLabel
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [25, 15, 15])
        
        activityIndicator
            .toRightOf(transactionLabel, constant: 5)
            .alignEdge(.centerY, withView: transactionLabel)

        filterButton
            .alignEdgesWithSuperview([.right, .top, .bottom], constants: [25, 15, 15])

         stackView
            .alignAllEdgesWithSuperview()
        
//        filterView
//            .alignEdgesWithSuperview([.top, .left, .right])
        
        filterViewSeprator
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .height(constant: 1)
        
        filterCount
            .centerVerticallyInSuperview()
            .toLeftOf(filterButton, constant: 5)
            .height(constant: 25)
            .width(constant: 25)

//        tableView
//            .toBottomOf(filterView)
//            .alignEdgesWithSuperview([.left, .right, .bottom])

        placeholderView.alignEdgeWithSuperview(.top, constant: 40)
            .alignEdgesWithSuperview([.left, .right], constant: 20)
        
        nothingLabel
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [25, 25, 50, 50])
        
        placeholderImageView
            .toBottomOf(nothingLabel, constant: 15)
            .alignEdgesWithSuperview([.left, .bottom, .right], constant: 25)
        
        noTransFoundLabel
            .centerVerticallyInSuperview()
            .centerHorizontallyInSuperview()
    }
}

// MARK: - Bind
fileprivate extension TransactionsViewController {
    func bind() {
        viewModel.outputs.filterCount.map { $0 == 0 }.bind(to: filterCount.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.filterCount.map { String($0) }.bind(to: filterCount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.filterCount
            .map { $0 == 0 ? UIImage(named: "icon_filter_primary_dark", in: .yapPakistan)?
                .asTemplate : nil }
            .bind(to: filterButton.rx.image(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.reloadData.subscribe(onNext: { [weak self] in self?.tableView.reloadData() }).disposed(by: disposeBag)
        viewModel.outputs.showsPlaceholder.map { !$0 }.bind(to: placeholderImageView.rx.isHidden).disposed(by: disposeBag)
        filterButton.rx.tap.bind(to: viewModel.inputs.openFilterObserver).disposed(by: disposeBag)
        viewModel.outputs.filterEnabled.bind(to: filterButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.filterEnabled.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.filterButton.tintColor = $0 ? UIColor(self.themeService.attrs.primary) : UIColor(self.themeService.attrs.greyDark)
        }).disposed(by: disposeBag)
        viewModel.outputs.showsNothingLabel.subscribe(onNext: { [weak self] in
            self?.nothingLabel.isHidden = !$0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.loading.subscribe(onNext: { [weak self] in
            $0 ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = !$0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.nothingLabelText.bind(to: nothingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showsFilter.map{ !$0 }.bind(to: filterView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.showLoadMoreIndicator.subscribe( onNext: { [weak self] (show) in
            guard let self = self else {return}
            if show {
                let loading = FooterLoadingView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 64))
                self.tableView.tableFooterView = loading
                loading.indicator.startAnimating()
            }else {
                self.tableView.tableFooterView = nil
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.noTransFound.bind(to: noTransFoundLabel.rx.text).disposed(by: disposeBag)
    }
}

// MARK: Table veiw datasource

extension TransactionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSection = viewModel.outputs.numberOfSections
        placeholderView.isHidden = numberOfSection > 0
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  viewModel.outputs.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.outputs.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: self.themeService, viewModel: cellViewModel)
        return cell
//        UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension TransactionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHeaderTableViewCell.defaultIdentifier) as! TransactionHeaderTableViewCell
        cell.configure(with: self.themeService, viewModel: viewModel.outputs.sectionViewModel(for: section))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46 //0 // return 46
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
        let currentVelocityYSign = Int(currentVelocityY).signum()
        if currentVelocityYSign != lastVelocityYSign &&
            currentVelocityYSign != 0 {
            lastVelocityYSign = currentVelocityYSign
        }
        
        Observable.just("").withLatestFrom(viewModel.outputs.enableLoadMore).subscribe(onNext: { [weak self] (enableLoadMore) in
            guard let `self` = self else {return}
//            print("scrollPercentage:\(self.tableView.scrollPercentage)")
            guard self.tableView.scrollPercentage > 0.6 ,
                  enableLoadMore else {return}
            self.viewModel.inputs.loadMore.onNext(())
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard !(cell is WelcomeToYapCell) else  {
            viewModel.inputs.openWelcomeTutorialObserver.onNext(())
            return
        }
        
//        guard let transaction = ((cell as? TransactionsTableViewCell)?.viewModel as? TransactionsTableViewCellViewModel)?.cdTransaction else { return }

        let cellViewModel = viewModel.outputs.cellViewModel(for: indexPath) as? TransactionsTableViewCellViewModel
        if let tranaction = cellViewModel?.transaction {
            var transactionNew = tranaction
            transactionNew.selectedCurrentIndex = indexPath.row
            viewModel.inputs.transactionDetailsObserver.onNext(transactionNew)
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard tableView.scrollPercentage > 0.6 else {return}
//        viewModel.inputs.loadMore.onNext(())
//    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let index = tableView.indexPathsForVisibleRows?.first?.section {
            viewModel.inputs.sectionObserver.onNext(index)
        }
    }
}

