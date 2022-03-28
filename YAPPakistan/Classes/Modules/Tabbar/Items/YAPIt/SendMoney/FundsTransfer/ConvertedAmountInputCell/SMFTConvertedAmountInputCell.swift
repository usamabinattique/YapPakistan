//
//  SMFTConvertedAmountInputCell.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxTheme


class SMFTConvertedAmountInputCell: RxUITableViewCell {

    // MARK: Views

    private lazy var equal = UIFactory.makeLabel(font: .title1, alignment: .center, numberOfLines: 0, text: "=")
    //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title1, alignment: .center, text: "=")

    private lazy var amountView: AmountView = {
        let vm = AmountViewModel(heading:  "custom_view_display_text_amount_view".localized)
        let view = AmountView(viewModel: vm)
        view.amountTextField.placeholder = CurrencyFormatter.defaultFormattedFee.split(separator: " ").last.map { String($0) }
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var rateStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 15)
    
    private lazy var rateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "icon_trending", in: .yapPakistan, compatibleWith: nil)
        imageView.tintColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var rate = UIFactory.makeLabel(font: .small)
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small)

    // MARK: Properties

    var viewModel: SMFTConvertedAmountInputCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
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
        selectionStyle = .none

        setupViews()
        setupConstraints()
    }

    // MARK: View cycle

    // MARK: Configurations

    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTConvertedAmountInputCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }

}

// MARK: View setup

private extension SMFTConvertedAmountInputCell {

    func setupViews() {
        contentView.addSubview(equal)
        contentView.addSubview(amountView)

        contentView.addSubview(rateStack)

        rateStack.addArrangedSubview(rateIcon)
        rateStack.addArrangedSubview(rate)
    }

    func setupConstraints() {

        equal
            .alignEdgeWithSuperview(.top)
            .centerHorizontallyInSuperview()

        amountView
            .toBottomOf(equal, constant: 10)
            .height(constant: 70)
            .width(constant: 175)
            .centerHorizontallyInSuperview()

        rateStack
            .toBottomOf(amountView, constant: 20)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, constant: 0)

    }
}

// MARK: Binding

private extension SMFTConvertedAmountInputCell {
    func bindViews() {
        viewModel.outputs.text.bind(to: amountView.amountTextField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.rate.bind(to: rate.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.currency.bind(to: amountView.headingLabel.rx.text).disposed(by: disposeBag)
        amountView.amountTextField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
    }
}
