//
//  CountryViewController.swift
//  Pods
//
//  Created by Sarmad on 20/10/2021.
//

import Foundation
import RxSwift
import YAPComponents
import RxTheme

class CountrysViewController: UIViewController {

    // MARK: Views
    private lazy var titleLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var searchTextField = UIFactory.makeTextField(font: .regular,
                                                               isCircular: true,
                                                               textAlignment: .center,
                                                               clearButtonMode: .always,
                                                               returnKeyType: .search )

    private lazy var tableView = UIFactory.makeTableView(allowsSelection: true)
    private var backButton: UIButton!

    // MARK: Properties

    private let themeService: ThemeService<AppTheme>
    let viewModel: CountryViewModelType

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: CountryViewModel) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Unsupported")
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupLanguage()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(searchTextField)
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.defaultIdentifier)
        backButton = addBackButton(of: .backEmpty)
        self.navigationItem.titleView = titleLabel
    }

    private func setupResources() {
        // viewModel.outputs.strings.withUnretained(self)
        let image = UIImage(named: "icon_close", in: .yapPakistan)?.asTemplate
        searchTextField.setClearImage(image, for: .normal)
    }

    func setupLanguage() {
        titleLabel.text = "Select your city"
        searchTextField.placeholder = "Search"
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyExtraLight) }, to: searchTextField.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: searchTextField.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: searchTextField.rx.placeholderColor)
            .bind({ UIColor($0.greyDark) }, to: searchTextField.rx.clearImageTint)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        searchTextField
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constants: [20, 20, 20])
            .height(constant: 35)
        tableView
            .toBottomOf(searchTextField, constant: -10)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        let cellid = LabelCell.defaultIdentifier
        let cellType = LabelCell.self
        viewModel.outputs.cellViewModels
            .bind(to: tableView.rx.items(cellIdentifier: cellid, cellType: cellType))
            { [weak self] _, viewModel, cell in guard let self = self else { return }
                cell.configure(with: self.themeService, viewModel: viewModel)
            }.disposed(by: rx.disposeBag)
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(LabelCellViewModel.self)
            .bind(to: viewModel.inputs.selectedItemObserver)
            .disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        searchTextField.rx.text.unwrap().bind(to: viewModel.inputs.searchObserver).disposed(by: rx.disposeBag)
    }
}
