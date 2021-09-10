//
//  ReferredFriendsViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 01/09/2021.
//

import HWPanModal
import RxCocoa
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class ReferredFriendsViewController: UIViewController {

    // MARK: Views

    private lazy var sheetIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 2
        return view
    }()

    private lazy var titleLabel = UIFactory.makeLabel(font: .large, alignment: .natural, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var subtitleLabel = UIFactory.makeLabel(font: .small, alignment: .natural, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    private var viewModel: ReferredFriendsViewModelType!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: ReferredFriendsViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(sheetIndicatorView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(separatorView)
        view.addSubview(tableView)

        tableView.register(ReferredFriendCell.self, forCellReuseIdentifier: ReferredFriendCell.defaultIdentifier)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.greyLight) }, to: sheetIndicatorView.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subtitleLabel.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: separatorView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        sheetIndicatorView
            .alignEdgeWithSuperview(.top, constant: 12)
            .centerHorizontallyInSuperview()
            .width(constant: 60)
            .height(constant:4)

        titleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(sheetIndicatorView, constant: 16)

        subtitleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(titleLabel, constant: 8)

        separatorView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(subtitleLabel, constant: 24)
            .height(constant: 1)

        tableView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(separatorView)
    }

    // MARK: Binding

    private func bindViewModel() {
        viewModel.outputs.titleText
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.subtitleText
            .bind(to: subtitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.hidesSeparator
            .bind(to: separatorView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.hidesFriends
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.friendList.bind(to: tableView.rx.items(cellIdentifier: ReferredFriendCell.defaultIdentifier, cellType: ReferredFriendCell.self)) { [weak self] (_, viewModel: ReferredFriendViewModelType, cell) in
            guard let self = self else { return }
            cell.configure(with: self.themeService, viewModel: viewModel)
        }.disposed(by: disposeBag)
    }

    // MARK: HWPanModalPresentable

    override func panScrollable() -> UIScrollView? {
        return tableView
    }

    override func shortFormHeight() -> PanModalHeight {
        return PanModalHeight(type: .content, height: 360)
    }

    override func longFormHeight() -> PanModalHeight {
        return PanModalHeight(type: .topInset, height: 64)
    }

    override func cornerRadius() -> CGFloat {
        return 16
    }

    override func showDragIndicator() -> Bool {
        return false
    }
}
