//
//  KYCQuestionsViewController.swift
//  Adjust
//
//  Created by Sarmad on 06/10/2021.
//

import Foundation
import RxSwift
import YAPComponents
import RxTheme

class KYCQuestionsViewController: UIViewController {

    // MARK: Views

    private lazy var titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private lazy var subHeadingLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private lazy var tableView = UIFactory.makeTableView(allowsSelection: true)
    private lazy var nextButton = UIFactory.makeAppRoundedButton(with: .regular)

    // MARK: Properties

    private let themeService: ThemeService<AppTheme>
    let viewModel: KYCQuestionViewModelType

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: KYCQuestionViewModel) {
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
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(tableView)
        view.addSubview(nextButton)
        tableView.register(KYCQuestionCell.self, forCellReuseIdentifier: KYCQuestionCell.defaultIdentifier)
    }

    private func setupResources() {
        titleLabel.text = "screen_kyc_review_details_screen_title".localized
        subHeadingLabel.text = "screen_kyc_review_details_screen_subtitle".localized
        nextButton.setTitle("common_button_next".localized, for: .normal)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeadingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [20, 20, 20])

        subHeadingLabel
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .toBottomOf(titleLabel, constant: 10)

        tableView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(subHeadingLabel, constant: 10)
            .toTopOf(nextButton, constant: 10)

        nextButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 190)
            .height(constant: 52)
    }

    // MARK: Binding

    func bindViewModel() {
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.cnicFields.bind(to: tableView.rx.items(cellIdentifier: KYCQuestionCell.defaultIdentifier,
                                                                 cellType: KYCQuestionCell.self)) {
            [weak self] (_, viewModel: KYCQuestionCellViewModelType, cell) in
            guard let self = self else { return }
            cell.configure(with: self.themeService, viewModel: viewModel)
        }.disposed(by: rx.disposeBag)

        nextButton.rx.tap
            .bind(to: viewModel.inputs.nextObserver)
            .disposed(by: rx.disposeBag)
    }
}

