//
//  SearchCell.swift
//  YAPPakistan
//
//  Created by Sarmad on 03/11/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class SearchCell: UITableViewCell, ReusableView {

    // MARK: Views

    lazy var containerView = UIFactory.makeView()
    lazy var valueLabel = UIFactory.makeLabel(font: .small, alignment: .natural, numberOfLines: 0)

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!
    private var viewModel: SearchCellViewModelType!
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
    }

    // MARK: View Setup

    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        selectionStyle = .none
    }

    private func setupConstraints() {
        containerView.alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [35, 25, 25, 0])
        valueLabel.alignEdgesWithSuperview([.right, .left, .top, .bottom])
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: valueLabel.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: containerView.rx.borderColor)
            .bind({ UIColor($0.backgroundColor) }, to: rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViewModel(_ viewModel: SearchCellViewModelType) {
        self.viewModel = viewModel
        self.viewModel.outputs.value.bind(to: valueLabel.rx.text).disposed(by: disposeBag)
    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>, viewModel: SearchCellViewModelType) {
        setupTheme(with: themeService)
        bindViewModel(viewModel)
    }
}
