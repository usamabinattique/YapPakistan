//
//  LimitsViewController.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift
import YAPComponents
import RxTheme

class LimitsViewController: UIViewController {
    // MARK: Views
    private lazy var titleLabel = UIFactory.makeLabel(font: .large, alignment: .center)

    let atmContainer = UIFactory.makeView()
    let atmTitle = UIFactory.makeLabel(font: .large)
    let atmDetail = UIFactory.makeLabel(font: .regular, numberOfLines: 0)
    let atmSwitch = UIFactory.makeAppSwitch()

    let retailContainer = UIFactory.makeView()
    let retailTitle = UIFactory.makeLabel(font: .large)
    let retailDetail = UIFactory.makeLabel(font: .regular, numberOfLines: 0)
    let retailSwitch = UIFactory.makeAppSwitch()

    private var backButton: UIButton!

    // MARK: Properties
    private let themeService: ThemeService<AppTheme>
    let viewModel: LimitsViewModelType

    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: LimitsViewModel) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSub(views: [atmContainer, retailContainer])
        atmContainer.addSub(views: [atmTitle, atmDetail, atmSwitch])
        retailContainer.addSub(views: [retailTitle, retailDetail, retailSwitch])
        navigationItem.titleView = titleLabel
        backButton = addBackButton(of: .closeEmpty)
    }

    private func setupResources() {
        atmSwitch.onImage = UIImage(named: "icon_check", in: .yapPakistan)?.asTemplate
        retailSwitch.onImage = UIImage(named: "icon_check", in: .yapPakistan)?.asTemplate

        viewModel.outputs.strings.withUnretained(self)
            .subscribe(onNext: { $0.0.titleLabel.text = $0.1.title })
            .disposed(by: rx.disposeBag)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to: atmTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: atmDetail.rx.textColor)
            .bind({ UIColor($0.primary        ) }, to: [atmSwitch.rx.onTintColor])
            .bind({ UIColor($0.greyLight      ) }, to: [atmSwitch.rx.offTintColor])
            .bind({ UIColor($0.primaryDark) }, to: retailTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: retailDetail.rx.textColor)
            .bind({ UIColor($0.primary        ) }, to: [retailSwitch.rx.onTintColor])
            .bind({ UIColor($0.greyLight      ) }, to: [retailSwitch.rx.offTintColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        atmContainer
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right], constants: [15, 0, 0])
        retailContainer
            .toBottomOf(atmContainer)
            .alignEdgesWithSuperview([ .left, .right])

        atmTitle
            .alignEdgesWithSuperview([.top, .left], constants: [15, 25])
        atmDetail
            .toBottomOf(atmTitle, constant: 15)
            .alignEdgesWithSuperview([.left, .bottom], constants: [25, 0])
        atmSwitch
            .toRightOf(atmTitle, constant: 16)
            .toRightOf(atmDetail, constant: 16)
            .alignEdgesWithSuperview([.right], constant: 25)
            .centerVerticallyWith(atmTitle)

        retailTitle
            .alignEdgesWithSuperview([.top, .left], constants: [30, 25])
        retailDetail
            .toBottomOf(retailTitle, constant: 15)
            .alignEdgesWithSuperview([.left, .bottom], constants: [25, 0])
        retailSwitch
            .toRightOf(retailTitle, constant: 16)
            .toRightOf(retailDetail, constant: 16)
            .alignEdgesWithSuperview([.right], constant: 25)
            .centerVerticallyWith(retailTitle)
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.withdrawl.bind(to: atmSwitch.rx.value).disposed(by: rx.disposeBag)
        viewModel.outputs.retail.bind(to: retailSwitch.rx.value).disposed(by: rx.disposeBag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.atmSwitch.rx.value
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .skip(1).debug()
                .bind(to: self.viewModel.inputs.withdrawlObserver).disposed(by: self.rx.disposeBag)
            self.retailSwitch.rx.value
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .skip(1).debug()
                .bind(to: self.viewModel.inputs.retailObserver).disposed(by: self.rx.disposeBag)
        }

        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.strings.withUnretained(self)
            .subscribe(onNext: { `self`, resource in
                self.titleLabel.text = resource.title

                self.atmTitle.text = resource.cellsData[0].title
                self.atmDetail.text = resource.cellsData[0].detail
                self.atmSwitch.isOn = resource.cellsData[0].isOn

                self.retailTitle.text = resource.cellsData[1].title
                self.retailDetail.text = resource.cellsData[1].detail
                self.retailSwitch.isOn = resource.cellsData[1].isOn
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.withUnretained(self)
            .subscribe(onNext: { `self`, error in
                self.showAlert(message: error)
            })
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Unsupported") }
}



///////////////
/*
class LimitsViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("Unsupported") }

    // MARK: Views
    private lazy var titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private lazy var tableView = UIFactory.makeTableView(allowsSelection: true)
    private var backButton: UIButton!

    // MARK: Properties
    private let themeService: ThemeService<AppTheme>
    let viewModel: LimitsViewModelType

    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: LimitsViewModel) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(tableView)
        navigationItem.titleView = titleLabel
        backButton = addBackButton(of: .backEmpty)
        tableView.register(TitleDetailCell.self, forCellReuseIdentifier: TitleDetailCell.defaultIdentifier)
    }

    private func setupResources() {
        viewModel.outputs.strings.withUnretained(self)
            .subscribe(onNext: {
                $0.0.titleLabel.text = $0.1.title
            })
            .disposed(by: rx.disposeBag)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        tableView
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop, .safeAreaBottom])
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.optionViewModels
            .bind(to: tableView.rx.items(cellIdentifier:TitleDetailCell.defaultIdentifier, cellType: TitleDetailCell.self)) {
                [weak self] (_, viewModel: TitleDetailCellViewModelType, cell) in
                guard let self = self else { return }
                cell.configure(with: self.themeService, viewModel: viewModel)
            }.disposed(by: rx.disposeBag)

//        tableView.rx.modelSelected(TitleDetailCellViewModel.self)
//            .bind(to: viewModel.inputs.selectedItemObserver)
//            .disposed(by: rx.disposeBag)

        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
    }
}
*/
