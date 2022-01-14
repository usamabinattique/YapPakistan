//
//  LabelCell.swift
//  Pods
//
//  Created by Sarmad on 20/10/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class LabelCell: UITableViewCell, ReusableView {

    // MARK: Views

    lazy var valueLabel = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 1)

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!
    private var viewModel: LabelCellViewModelType!
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
    }

    // MARK: View Setup

    private func setupViews() {
        contentView.addSubview(valueLabel)
    }

    private func setupConstraints() {
        valueLabel
            .alignEdgesWithSuperview([.right, .left, .top, .bottom], constants: [30, 30, 15, 15])
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: valueLabel.rx.textColor)
            .bind({ _ in .clear }, to: rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViewModel(_ viewModel: LabelCellViewModelType) {
        self.viewModel = viewModel
        self.viewModel.outputs.value.bind(to: valueLabel.rx.text).disposed(by: disposeBag)
    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>, viewModel: LabelCellViewModelType) {
        setupTheme(with: themeService)
        bindViewModel(viewModel)
    }
}
