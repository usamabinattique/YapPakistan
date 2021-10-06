//
//  KYCReviewDetailsViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 30/09/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCReviewDetailsViewController: UIViewController {

    // MARK: Views

    private lazy var titleLabel = UIFactory.makeLabel(
        font: .title2,
        alignment: .center,
        text: "screen_kyc_review_details_screen_title".localized)

    private lazy var subHeadingLabel = UIFactory.makeLabel(
        font: .regular,
        alignment: .center,
        numberOfLines: 0,
        lineBreakMode: .byWordWrapping,
        text: "screen_kyc_review_details_screen_subtitle".localized)

    private lazy var cardView: KYCDocumentView = {
        let view = KYCDocumentView()
        view.viewType = .detailsOnly
        view.title = "screen_kyc_review_details_cnic_number".localized
        view.details = ""
        view.icon = UIImage(named: "kyc-user", in: .yapPakistan)
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    private lazy var nextButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title = "common_button_next".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: Properties

    private let disposeBag = DisposeBag()
    private let themeService: ThemeService<AppTheme>

    let viewModel: KYCReviewDetailsViewModelType

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: KYCReviewDetailsViewModelType) {
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
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(cardView)
        view.addSubview(tableView)
        view.addSubview(nextButton)

        tableView.register(KYCReviewFieldCell.self, forCellReuseIdentifier: KYCReviewFieldCell.defaultIdentifier)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeadingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: cardView.rx.iconTintColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.titleColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.detailsColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.subTitleColor)
            .bind({ UIColor($0.backgroundColor) }, to: cardView.rx.subDetailsColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .disposed(by: disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [20, 20, 20])

        subHeadingLabel
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .toBottomOf(titleLabel, constant: 10)

        cardView
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .height(constant: 70)
            .toBottomOf(subHeadingLabel, constant: 35)

        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(cardView, constant: 8)
            .toTopOf(nextButton, constant: 8)

        nextButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 190)
            .height(constant: 52)
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.cnicNumber
            .bind(to: cardView.rx.details)
            .disposed(by: disposeBag)

        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: disposeBag)

        viewModel.outputs.cnicFields.bind(to: tableView.rx.items(cellIdentifier: KYCReviewFieldCell.defaultIdentifier,
                                                                 cellType: KYCReviewFieldCell.self)) {
            [weak self] (_, viewModel: KYCReviewFieldViewModelType, cell) in
            guard let self = self else { return }
            cell.configure(with: self.themeService, viewModel: viewModel)
        }.disposed(by: disposeBag)

        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextObserver)
            .disposed(by: disposeBag)
    }
}
