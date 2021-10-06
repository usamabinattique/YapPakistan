//
//  KYCQuestionCell.swift
//  Adjust
//
//  Created by Sarmad on 06/10/2021.
//

import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCQuestionCell: UITableViewCell, ReusableView {

    // MARK: Views

    lazy var containerView = UIFactory.makeView(cornerRadious: 12, borderWidth: 1)
    lazy var valueLabel = UIFactory.makeLabel(font: .small, alignment: .natural, numberOfLines: 1)

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!
    private var viewModel: ReferredFriendViewModelType!
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
        UIView.animate(withDuration: 1) { [weak self] in guard let self = self else { return }
            self.containerView.backgroundColor = self.isSelected ? UIColor(self.themeService.attrs.greyLight):.clear
        }
    }

    // MARK: View Setup

    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        selectionStyle = .none
    }

    private func setupConstraints() {
        containerView
            .alignEdgesWithSuperview([.right, .left, .top, .bottom], constants: [30, 30, 8, 8])
            .aspectRatio(70 / 313, .defaultHigh)
        valueLabel
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
    }

    // MARK: Theming

    private func setupTheme(with themeService: ThemeService<AppTheme>) {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: valueLabel.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: containerView.rx.borderColor)
            .bind({ UIColor($0.primary) }, to: valueLabel.rx.textColor)
            .disposed(by: disposeBag)
    }

    // MARK: Binding

    private func bindViewModel(_ viewModel: KYCQuestionCellViewModelType) {
        viewModel.outputs.value
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: Configuration

    func configure(with themeService: ThemeService<AppTheme>, viewModel: KYCQuestionCellViewModelType) {
        setupTheme(with: themeService)
        bindViewModel(viewModel)
    }
}

