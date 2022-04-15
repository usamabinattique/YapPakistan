//
//  HomeTransactionsViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//
/*
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import YAPCore
import YAPComponents

//import CoreData

public class HomeTransactionsViewController: UIViewController {

    // MARK: - Init
    public init(viewModel: TransactionsViewModelType) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Views
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "image_empty_transaction", in: cardsBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nothingLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_home_display_text_nothing_to_report".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_home_display_text_nothing_to_report".localized)

    lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.isHidden = true
        nothingLabel.isHidden = true
        view.addSubview(placeholderImageView)
        view.addSubview(nothingLabel)
        return view
    }()
    
    lazy var filterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 0, arrangedSubviews: [filterView, tableView])
    
    lazy var filterCount: PaddedLabel = {
        let label = PaddedLabel()
//        label.backgroundColor = UIColor.primary.withAlphaComponent(0.17)
//        label.textColor = .primary
        label.textAlignment = .center
        label.font = .micro
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var transactionLabel: UILabel = UIFactory.makeLabel(font: .regular text: "Transactions".localized) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .regular, text:  "Transactions".localized)
    
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
//        button.setImage(UIImage(named: "icon_filter_primary_dark", in: cardsBundle, compatibleWith: nil)?.asTemplate, for: .normal)
//        button.setTitleColor(.primary, for: .normal)
//        button.setTitleColor(.grey, for: .disabled)
        button.titleLabel?.font = .regular
//        button.tintColor = .primary
        return button
    }()

    lazy var filterViewSeprator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.greyDark.withAlphaComponent(0.11)
        return view
    }()
    
    private var visibleHeaderView = [Int: UIView]()

    // MARK: - Properties
    let viewModel: TransactionsViewModelType
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<(date: String, amount: String), ReusableTableViewCellViewModelType>>!
    let disposeBag: DisposeBag
    var lastVelocityYSign = 0

    // MARK: - View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        viewModel.inputs.viewDidLoadObsever.onNext(())
        setup()
        bind()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewAppearedObsever.onNext(())
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        filterCount.clipsToBounds = true
        filterCount.layer.cornerRadius = 12.5
    }
}

// MARK: - Setup
fileprivate extension HomeTransactionsViewController {
    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        view.backgroundColor = .white
//        view.addSubview(tableView)
        
        view.addSubview(stackView)
        
        tableView.tableFooterView = UIView()

        tableView.showsVerticalScrollIndicator = false
        tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.reuseIdentifier)
        tableView.register(TransactionHeaderTableViewCell.self, forCellReuseIdentifier: TransactionHeaderTableViewCell.reuseIdentifier)
        tableView.register(BottomLoadingTableViewCell.self, forCellReuseIdentifier: BottomLoadingTableViewCell.reuseIdentifier)
        tableView.register(WelcomeToYapCell.self, forCellReuseIdentifier: WelcomeToYapCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        view.addSubview(placeholderView)

        filterView.addSubview(transactionLabel)
        filterView.addSubview(filterButton)
        filterView.addSubview(filterViewSeprator)
        filterView.addSubview(filterCount)
        filterView.addSubview(activityIndicator)

//        view.addSubview(filterView)
    }
    
    private func applyShadowToTopStucksection() {
        
        if let visibleRows = tableView.indexPathsForVisibleRows {
            if  let visibleMinSection = visibleRows.map({$0.section}).min() {
                let myHeaderView = visibleHeaderView[visibleMinSection]
                for (_, value) in visibleHeaderView {
                    if let headerView = value as? TransactionHeaderTableViewCell {
                        headerView.removeShadow()
                    }
                }
                if let headerView = myHeaderView as? TransactionHeaderTableViewCell {
                    headerView.addShadow()
                }
                
            }
        }
    }

    func setupConstraints() {

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
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 50, 25])
        
        placeholderImageView
            .toBottomOf(nothingLabel, constant: 15)
            .alignEdgesWithSuperview([.left, .bottom, .right], constant: 25)

    }
}

// MARK: - Bind
fileprivate extension HomeTransactionsViewController {
    func bind() {
        viewModel.outputs.filterCount.map { $0 == 0 }.bind(to: filterCount.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.filterCount.map { String($0) }.bind(to: filterCount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.filterCount.map { $0 == 0 ? UIImage() /*UIImage(named: "icon_filter_primary_dark", in: cardsBundle, compatibleWith: nil)?.asTemplate */ : nil }.bind(to: filterButton.rx.image(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.reloadData.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        viewModel.outputs.showsPlaceholder.map { !$0 }.bind(to: placeholderImageView.rx.isHidden).disposed(by: disposeBag)
        filterButton.rx.tap.bind(to: viewModel.inputs.openFilterObserver).disposed(by: disposeBag)
        viewModel.outputs.filterEnabled.bind(to: filterButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.filterEnabled.subscribe(onNext: { [weak self] in
//            self?.filterButton.tintColor = $0 ? .primary : .greyDark
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
        viewModel.outputs.showError.subscribe(onNext: { [weak self] in
            self?.showAlert(message: $0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.showLoader.subscribe(onNext: { showLoader in
            showLoader ? YAPProgressHud.showProgressHud()  : YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }
}

// MARK: Table veiw datasource

extension HomeTransactionsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSection = viewModel.outputs.numberOfSections
        placeholderView.isHidden = numberOfSection > 0
        return numberOfSection
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.numberOfRows(inSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.outputs.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeTransactionsViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHeaderTableViewCell.reuseIdentifier) as! TransactionHeaderTableViewCell
        cell.configure(with: viewModel.outputs.sectionViewModel(for: section))
        self.viewModel.inputs.isDataReloaded.onNext(true)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
        let currentVelocityYSign = Int(currentVelocityY).signum()
        if currentVelocityYSign != lastVelocityYSign &&
            currentVelocityYSign != 0 {
            lastVelocityYSign = currentVelocityYSign
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let index = tableView.indexPathsForVisibleRows?.first?.section {
            viewModel.inputs.sectionObserver.onNext(index)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard !(cell is WelcomeToYapCell) else  {
            viewModel.inputs.openWelcomeTutorialObserver.onNext(())
            return
        }
        
        guard let transaction = ((cell as? TransactionsTableViewCell)?.viewModel as? TransactionsTableViewCellViewModel)?.cdTransaction else { return }
        
        viewModel.inputs.transactionDetailsObserver.onNext(transaction)
    }
    
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        visibleHeaderView[section] = nil
        applyShadowToTopStucksection()
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    
        visibleHeaderView[section] = view
        applyShadowToTopStucksection()
    }
}
*/
