//
//  KYCReviewFieldCell.swift
//  YAPPakistan
//
//  Created by Tayyab on 29/09/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCReviewFieldCell: UITableViewCell, ReusableView {

    // MARK: Views

    lazy var headingLabel = UIFactory.makeLabel(
        font: .small, alignment: .natural, numberOfLines: 1)

    lazy var valueLabel = UIFactory.makeLabel(
        font: .large, alignment: .natural, numberOfLines: 1)

    private lazy var tickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_check", in: .yapPakistan)
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private var disposeBag = DisposeBag()
    private var viewModel: ReferredFriendViewModelType!

    // MARK: Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupViews()
        setupConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }

    // MARK: View Setup

    private func setupViews() {
        contentView.addSubview(headingLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(tickImageView)

        selectionStyle = .none
    }

    private func setupConstraints() {
        headingLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [20, 20, 8])

        valueLabel
            .alignEdgeWithSuperview(.left, constant: 20)
            .toBottomOf(headingLabel, constant: 4)
            .alignEdgeWithSuperview(.bottom, constant: 8)

        tickImageView
            .toRightOf(valueLabel)
            .alignEdgeWithSuperview(.right, constant: 20)
            .centerVerticallyWith(valueLabel)
            .width(constant: 32)
            .height(constant: 32)
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: valueLabel.rx.textColor)
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViewModel(_ viewModel: KYCReviewFieldViewModelType) {
        viewModel.outputs.heading
            .bind(to: headingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.value
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>,
                   viewModel: KYCReviewFieldViewModelType) {
        setupTheme(with: themeService)
        bindViewModel(viewModel)
    }
}
