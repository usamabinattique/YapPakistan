//
//  SMFTAmountInputCell.swift
//  YAP
//
//  Created by Zain on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxTheme

class SMFTAmountInputCell: RxUITableViewCell {

    // MARK: Views

    private lazy var currencyLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    //UIFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)

    private lazy var amountView: AmountView = {
        let vm = AmountViewModel(heading:  "custom_view_display_text_amount_view".localized)
        let view = AmountView(viewModel: vm)
        view.amountTextField.placeholder =  "custom_view_display_text_amount_view_initial_value".localized
        view.amountTextField.inputAccessoryView = toolbar
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var toolbar: UIView = {
        return UIView()
//        return getToolBar(target: self, done: #selector(endEditingAction), cancel: #selector(endEditingAction))
    }()

    // MARK: Properties

    var viewModel: SMFTAmountInputCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    private var decimalPlaces: Int = 2 {
        didSet {
            amountView.allowedDecimal = decimalPlaces
        }
    }

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

    // MARK: Configurations

    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTAmountInputCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }

    // MARK: Actions

    @objc
    func endEditingAction() {
        endEditing(true)
        viewModel.inputs.endEditingObserver.onNext(())
    }
}

// MARK: View setup

private extension SMFTAmountInputCell {

    func setupViews() {
        contentView.addSubview(currencyLabel)
        contentView.addSubview(amountView)
    }

    func setupConstraints() {

        currencyLabel
            .alignEdgeWithSuperview(.top)
            .centerHorizontallyInSuperview()

        amountView
            .toBottomOf(currencyLabel, constant: 8)
            .width(constant: 175)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom)

        amountView
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [10, 0, 10, 0])

    }
}

// MARK: Binding

private extension SMFTAmountInputCell {
    func bindViews() {
        viewModel.outputs.currency.bind(to: amountView.headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.text.bind(to: amountView.amountTextField.rx.text).disposed(by: disposeBag)
        amountView.amountTextField.rx.text.map { $0?.removingGroupingSeparator() }.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)

//        viewModel.outputs.isValidAmount.subscribe(onNext: { [weak self] valid in
//            guard let `self` = self else { return }
//            self.amountView.amountContainerView.layer.borderWidth = valid ? 0 : 1
//            self.amountView.amountContainerView.layer.borderColor = valid ? self.amountView.amountTextField.backgroundColor?.cgColor : UIColor.red
//        }).disposed(by: disposeBag)
        
        viewModel.outputs.allowedDecimalPlaces.subscribe(onNext: { [weak self] in
            self?.decimalPlaces = $0
        }).disposed(by: disposeBag)
    }
}
