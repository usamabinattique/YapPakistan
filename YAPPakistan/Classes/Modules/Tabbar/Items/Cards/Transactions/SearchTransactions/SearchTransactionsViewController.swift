//
//  SearchTransactionsViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 19/04/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class SearchTransactionsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var searchBar: UITextField = {
        let searchBar = UITextField()
        searchBar.attributedPlaceholder = NSAttributedString(string: "Search for transaction", attributes: [.foregroundColor: UIColor(themeService.attrs.greyDark)])
        searchBar.font = .regular
        searchBar.borderStyle = .none
        searchBar.backgroundColor = .white
        searchBar.returnKeyType = .done
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_close", in: .yapPakistan)?.asTemplate, for: .normal)
        button.backgroundColor = .clear
//        button.tintColor = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var transactionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var transactionViewController: TransactionsViewController = {
        let viewController = TransactionsViewController(viewModel: viewModel.outputs.transactionsViewModel, themeService: themeService)
        return viewController
    }()
    
    private lazy var noTransFoundLabel = UIFactory.makeLabel(font: .large,
                                                        alignment: .center,
                                                        numberOfLines: 1,
                                                        lineBreakMode: .byWordWrapping)
    
    // MARK: Properties
    
    private var viewModel: SearchTransactionsViewModelType!
    private let disposeBag = DisposeBag()
    let themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    init(viewModel: SearchTransactionsViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
        setupTheme()
    }

    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews(viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

// MARK: Setup Views

private extension SearchTransactionsViewController {
    
    func setupViews() {
        
        view.addSubview(closeButton)
        view.addSubview(searchBar)
        view.addSubview(separator)
        view.addSubview(transactionContainer)
        
        performTransactionsContainment()
        
        view.backgroundColor = .white
    }
    
    func setupConstraints() {
        
        closeButton
            .alignEdgeWithSuperviewSafeArea(.top, constant: 10)
            .alignEdgeWithSuperview(.left, constant: 21)
            .width(constant: 26)
            .height(constant: 26)
        
        searchBar
            .alignEdgeWithSuperview(.right, constant: 26)
            .alignEdge(.centerY, withView: closeButton)
            .toRightOf(closeButton, constant: 42)
            .height(constant: 24)
        
        separator
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(searchBar, constant: 9)
            .height(constant: 1)
        
        transactionViewController.view
            .alignAllEdgesWithSuperview()
        
        transactionContainer
            .toBottomOf(separator)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [searchBar.rx.tintColor,closeButton.rx.tintColor])
            .bind({ UIColor($0.greyDark) }, to: [noTransFoundLabel.rx.textColor])
            .disposed(by: disposeBag)
    }
    
    func performTransactionsContainment() {
        addChild(transactionViewController)
        transactionContainer.addSubview(transactionViewController.view)
    }
}

// MARK: Binding

private extension SearchTransactionsViewController {
    func bindViews(_ viewModel: SearchTransactionsViewModelType) {
        
        closeButton.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: disposeBag)
        searchBar.rx.text.bind(to: viewModel.inputs.searchTextObserver).disposed(by: disposeBag)
        
        viewModel.outputs.noTransFound.withUnretained(self).subscribe(onNext:  { `self`, text in
            self.noTransFoundLabel.text = text
            self.transactionContainer.removeSubviews()
            self.transactionContainer.addSubview(self.noTransFoundLabel)
            self.noTransFoundLabel.alignCenterWith(self.transactionContainer)
        }).disposed(by: disposeBag)
    }
}


// MARK: - Keyboard handling

private extension SearchTransactionsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            transactionViewController.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15 - view.safeAreaInsets.bottom, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        transactionViewController.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
