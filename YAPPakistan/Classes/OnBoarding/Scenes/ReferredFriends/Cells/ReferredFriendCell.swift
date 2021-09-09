//
//  ReferredFriendCell.swift
//  YAPPakistan
//
//  Created by Tayyab on 02/09/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class ReferredFriendCell: UITableViewCell {

    // MARK: Views

    private lazy var initialsImageView: InitialsImageView = {
        let view = InitialsImageView()
        view.setLabelFont(.regular)
        return view
    }()

    private lazy var nameLabel = UIFactory.makeLabel(font: .small, alignment: .natural, numberOfLines: 2)

    // MARK: Properties

    static var defaultIdentifier: String { "ReferredFriendCell" }

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
        contentView.addSubview(initialsImageView)
        contentView.addSubview(nameLabel)

        selectionStyle = .none
    }

    private func setupConstraints() {
        initialsImageView
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [28, 10, 10])
            .width(42)
            .height(42)

        nameLabel
            .alignEdgesWithSuperview([.right, .top], constants: [28, 16])
            .toRightOf(initialsImageView, constant: 20)
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: nameLabel.rx.textColor)
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViews(with viewModel: ReferredFriendViewModelType) {
        viewModel.outputs.initialsBackgroundColor
            .map { UIColor($0 ?? Color(hex: "#FFFFFF")).withAlphaComponent(0.16) }
            .bind(to: initialsImageView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.outputs.initialsTextColor
            .map { UIColor($0 ?? Color(hex: "#FFFFFF")) }
            .bind(to: initialsImageView.rx.labelColor)
            .disposed(by: disposeBag)

        viewModel.outputs.friendName
            .bind(to: initialsImageView.rx.initials)
            .disposed(by: disposeBag)

        viewModel.outputs.friendName
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>, viewModel: ReferredFriendViewModelType) {
        setupTheme(with: themeService)
        bindViews(with: viewModel)
    }
}
