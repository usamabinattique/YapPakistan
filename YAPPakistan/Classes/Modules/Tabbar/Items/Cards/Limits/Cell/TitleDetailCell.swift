//
//  TitleDetailCell.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 29/11/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class TitleDetailCell: UITableViewCell, ReusableView {

    // MARK: Views
    let titleLabel = UIFactory.makeLabel(font: .regular)
    let detailLabel = UIFactory.makeLabel(font: .small, numberOfLines: 0)
    let `switch` = UIFactory.makeAppSwitch()

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!
    private var viewModel: TitleDetailCellViewModelType!
    private var disposeBag = DisposeBag()

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

    // MARK: Cell selection

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.viewModel.inputs.selectedObserver.onNext(self.isSelected)
        self.switch.isOn = selected
    }

    // MARK: View Setup

    private func setupViews() {
        contentView.addSub(views: [titleLabel, detailLabel, `switch`])
        selectionStyle = .none
        `switch`.onImage = UIImage(named: "icon_check", in: .yapPakistan)?.asTemplate
    }

    private func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.top, .left], constant: 25)

        detailLabel
            .toBottomOf(titleLabel, constant: 25)
            .alignEdgesWithSuperview([.left, .bottom], constant: 25)

        `switch`
            .toRightOf(titleLabel, constant: 16)
            .toRightOf(detailLabel, constant: 16)
            .alignEdgesWithSuperview([.right], constant: 25)
            .centerVerticallyWith(titleLabel)
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: detailLabel.rx.borderColor)
            .bind({ UIColor($0.primary        ) }, to: [`switch`.rx.onTintColor])
            .bind({ UIColor($0.greyLight      ) }, to: [`switch`.rx.offTintColor])
            .bind({ _ in .clear }, to: [rx.backgroundColor, contentView.rx.backgroundColor])
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViewModel(_ viewModel: TitleDetailCellViewModelType) {
        self.viewModel = viewModel

        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.detail.bind(to: detailLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.selected.bind(to: rx.isSelected).disposed(by: rx.disposeBag)

    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>, viewModel: TitleDetailCellViewModelType) {
        setupTheme(with: themeService)
        bindViewModel(viewModel)
    }
}

