//
//  BankListSearchViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 16/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

class BankListSearchViewController: UIViewController {
    
    // MARK: Views
    private lazy var searchBar: AppSearchBar = {
       let searchBar = AppSearchBar()
        searchBar.textField.placeholder = "Search banks"
       searchBar.autoHidesCancelButton = false
       searchBar.delegate = self
       searchBar.translatesAutoresizingMaskIntoConstraints = false
       return searchBar
    }()
    
    private lazy var yapContactLabel: PaddedLabel = {
       let label = PaddedLabel()
       label.font = .small
       //label.textColor = .primaryDark
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    private lazy var contactStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, arrangedSubviews: [yapContactLabel, tableView])
    
    // MARK: Properties
    private var viewModel: BankListSearchViewModelType!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var tableViewBottom: NSLayoutConstraint!
    private var themeService:ThemeService<AppTheme>!
    
    // MARK: Initialization
    init(themeService:ThemeService<AppTheme>,viewModel: BankListSearchViewModelType) {
        self.themeService = themeService
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupConstraints()
        bindViews()
        bindTableView()
        
        if UIScreen.screenType != .iPhone5 {
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Actions
    @objc
    private func tapped(_ tap: UITapGestureRecognizer) {
       view.endEditing(true)
    }
}

// MARK: View setup
extension BankListSearchViewController {

    func setupViews() {
    view.backgroundColor = .white
    view.addSubview(searchBar)
    view.addSubview(contactStack)
        
    tableView.register(AddBeneficiaryCell.self, forCellReuseIdentifier: AddBeneficiaryCell.defaultIdentifier)
    tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.defaultIdentifier)
   }
   
   func setupConstraints() {
    searchBar
        .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
        .height(constant: 35)
    
    contactStack
        .alignEdgesWithSuperview([.left, .right])
        .toBottomOf(searchBar, constant: 10)
    
    yapContactLabel.leftInset = 25
    
    tableViewBottom = view.bottomAnchor.constraint(equalTo: contactStack.bottomAnchor)
    tableViewBottom.isActive = true
    
    tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 15, right: 0)
   }
}

// MARK: Binding
private extension BankListSearchViewController {
    
    func bindViews() {
        searchBar.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        searchBar.rx.cancelTap
            .do(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            .bind(to: viewModel.inputs.cancelObserver)
            .disposed(by: disposeBag)
        viewModel.outputs.billerText.bind(to: yapContactLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.billerText.map { $0 == nil }.bind(to: yapContactLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            //guard let `self` = self else { return }
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}

// MARK: Search Bar delegate
extension BankListSearchViewController: AppSearchBarDelegate { }

// MARK: Keyboard handling
private extension BankListSearchViewController {
   
   @objc func keyboardWillShow(notification: NSNotification) {
      if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
         tableViewBottom.constant = keyboardSize.height
         UIView.animate(withDuration: 0.25) { [unowned self] in
            self.view.layoutSubviews()
         }
      }
   }
   
   @objc func keyboardWillHide(notification: NSNotification) {
      self.tableViewBottom.constant = 0
      UIView.animate(withDuration: 0.25) { [unowned self] in
         self.view.layoutSubviews()
      }
   }
}

