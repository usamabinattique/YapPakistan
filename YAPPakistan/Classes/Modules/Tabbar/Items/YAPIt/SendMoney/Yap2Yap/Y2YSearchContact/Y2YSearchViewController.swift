//
//  Y2YSearchViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 17/01/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme

class Y2YSearchViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var searchBar: AppSearchBar = {
        let searchBar = AppSearchBar()
        searchBar.autoHidesCancelButton = false
        //      searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var yapContactsButton: UIButton = UIFactory.makeButton(with: .micro, title: "screen_y2y_display_button_yap_contacts".localized)
    
    private lazy var allContactButton: UIButton = UIFactory.makeButton(with: .micro, title: "screen_y2y_display_button_all_contacts".localized)
    
    private lazy var contactButtonStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 20, arrangedSubviews: [yapContactsButton, allContactButton])
    
    private lazy var yapContactLabel = UIFactory.makeLabel(font: .small, insects: UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 7))
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var contactStack = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0, arrangedSubviews: [yapContactLabel, tableView])
    
    // MARK: Properties
    
    private var viewModel: Y2YSearchViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    private var tableViewBottom: NSLayoutConstraint!
    
    // MARK: Initialization
    
    init(viewModel: Y2YSearchViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        
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

extension Y2YSearchViewController: ViewDesignable {
    
    func setupSubViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(contactButtonStack)
        view.addSubview(contactStack)
        
        tableView.register(Y2YContactCell.self, forCellReuseIdentifier: Y2YContactCell.defaultIdentifier)
        tableView.register(NoSearchResultCell.self, forCellReuseIdentifier: NoSearchResultCell.defaultIdentifier)
        
        allContactButton.layer.cornerRadius = 10
        allContactButton.clipsToBounds = true
        
        yapContactsButton.layer.cornerRadius = 10
        yapContactsButton.clipsToBounds = true
    }
    
    func setupConstraints() {
        searchBar
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 15, 25])
            .height(constant: 35)
        
        contactButtonStack
            .centerHorizontallyInSuperview()
            .toBottomOf(searchBar, constant: 20)
        
        yapContactsButton
            .width(constant: 100)
            .height(constant: 20)
        
        allContactButton
            .width(with: .width, ofView: yapContactsButton)
            .height(with: .height, ofView: yapContactsButton)
        
        contactStack
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(contactButtonStack, constant: 10)
        
        yapContactLabel.leftTextInset = 25
        
        tableViewBottom = view.bottomAnchor.constraint(equalTo: contactStack.bottomAnchor)
        tableViewBottom.isActive = true
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 15, right: 0)
    }
    
    func setupBindings() {
        searchBar.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        searchBar.rx.cancelTap
            .do(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            .bind(to: viewModel.inputs.cancelObserver)
            .disposed(by: rx.disposeBag)
        
        yapContactsButton.rx.tap
            .do(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.allContactButton.backgroundColor = .clear
                self.yapContactsButton.backgroundColor = UIColor((self.themeService.attrs.primary)).withAlphaComponent(0.15)
            })
            .bind(to: viewModel.inputs.yapContactObserver).disposed(by: rx.disposeBag)
                    
        allContactButton.rx.tap
            .do(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.yapContactsButton.backgroundColor = .clear
                self.allContactButton.backgroundColor = UIColor(self.themeService.attrs.primary).withAlphaComponent(0.15)
            })
            .bind(to: viewModel.inputs.allContactObserver).disposed(by: rx.disposeBag)
                        
        viewModel.outputs.contactText.bind(to: yapContactLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.contactText.map { $0 == nil }.bind(to: yapContactLabel.rx.isHidden).disposed(by: rx.disposeBag)
        
        viewModel.outputs.refreshData.subscribe(onNext: { [weak self] in self?.tableView.reloadData() }).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [yapContactLabel.rx.textColor])
            .bind({ UIColor($0.primary).withAlphaComponent(0.15) }, to: [yapContactsButton.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [yapContactsButton.rx.titleColor(for: .normal)])
            .bind({ $0.clear }, to: [allContactButton.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [allContactButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
}

// MARK: Search Bar delegate

extension Y2YSearchViewController: AppSearchBarDelegate { }

// MARK: Tableveiw data source

extension Y2YSearchViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModel.outputs.numberOfCells
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cellViewMdodel = viewModel.outputs.model(forIndex: indexPath)
      let cell = tableView.dequeueReusableCell(withIdentifier: cellViewMdodel.reusableIdentifier) as! ConfigurableTableViewCell
      cell.setIndexPath(indexPath)
       cell.configure(with: self.themeService, viewModel: viewModel.outputs.model(forIndex: indexPath))
      return cell as! UITableViewCell
   }
}

// MARK: Table view delegate

extension Y2YSearchViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      viewModel.inputs.cellSelected(at: indexPath)
   }
}

// MARK: Keyboard handling

private extension Y2YSearchViewController {
    
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
