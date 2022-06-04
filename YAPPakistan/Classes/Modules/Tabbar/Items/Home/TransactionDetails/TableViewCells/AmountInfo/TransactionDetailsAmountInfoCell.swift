//
//  TransactionDetailsAmountInfoCell.swift
//  YAP
//
//  Created by Wajahat Hassan on 21/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import SDWebImage
import RxTheme
import RxTheme
import UIKit

public class TransactionDetailsAmountInfoCell: RxUITableViewCell {
    
   /* private lazy var paymentInfo = UIFactory.makeLabel(font: .small, alignment: .left,  text: "Payment details") //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .left, text: "Payment details")
    
    private lazy var cancelReason = UIFactory.makeLabel(font: .micro, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping) */
    
    private lazy var cardHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "Card") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "Card")
    private lazy var cardValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var cardStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [cardHeading, cardValue])
    
   /* private lazy var foreignAmountHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "Transfer amount") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "Transfer amount")
    private lazy var foreignAmountValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var foreignAmountStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [foreignAmountHeading, foreignAmountValue])
    
    private lazy var exchangeRateHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "Exchange rate") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "Exchange rate")
    private lazy var exchangeRateValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var exchangeRateStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [exchangeRateHeading, exchangeRateValue])
    
    private lazy var nameHeading = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left)
    private lazy var nameValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var nameStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 15, arrangedSubviews: [nameHeading, nameValue])
    
    private lazy var amountHeading = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left)
    private lazy var amountValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var amountStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [amountHeading, amountValue])
    
    private lazy var feeHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "screen_transaction_details_display_text_fee".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "screen_transaction_details_display_text_fee".localized)
    private lazy var feeValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var feeStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [feeHeading, feeValue])
    
    private lazy var vatHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "screen_transaction_details_display_text_vat".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "screen_transaction_details_display_text_vat".localized)
    private lazy var vatValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var vatStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [vatHeading, vatValue])
    
    private lazy var totalAmountHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "screen_transaction_details_display_text_total_amount".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "screen_transaction_details_display_text_total_amount".localized)
    private lazy var totalAmountValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var totalAmountStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [totalAmountHeading, totalAmountValue]) */
    
    private lazy var referenceHeading = UIFactory.makeLabel(font: .small, alignment: .left,  text: "screen_transaction_details_display_text_refrence_number".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "screen_transaction_details_display_text_refrence_number".localized)
    private lazy var referenceValue = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    private lazy var referenceStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [referenceHeading, referenceValue])
    
 /*   private lazy var remarksHeading = UIFactory.makeLabel(font: .small, alignment: .left, text: "Remarks".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left, text: "Remarks".localized)
    private lazy var remarksValue = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right,  numberOfLines: 0)
    private lazy var paymentDetailsStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, arrangedSubviews: [paymentInfo])
    
    private lazy var remarksContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var remarksStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, arrangedSubviews: [remarksContainerView]) */
    
//    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 15, arrangedSubviews: [cancelReason, cardStack, foreignAmountStack, exchangeRateStack, nameStack, amountStack, feeStack, vatStack, totalAmountStack, referenceStack, remarksStack])
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 15, arrangedSubviews: [ cardStack, referenceStack])
    
    private lazy var shadedView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 248, green: 248, blue: 252) //.cell
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: TransactionDetailsAmountInfoCellViewModel!
    private var themeService: ThemeService<AppTheme>!
    private var isHiddenPaymentDetailsFlag: Bool = false
    private var paymentDetailsStackViewHeightConstraints: NSLayoutConstraint!
//    private var shadedViewConstraints: NSLayoutConstraint!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        setupViews()
        setupConstraints()
        setupSensitiveViews()
    }
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TransactionDetailsAmountInfoCellViewModel else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionDetailsAmountInfoCellViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
//        setupResources()
    }
    
}

// MARK: SetupViews
private extension TransactionDetailsAmountInfoCell {
    func setupViews() {
//        remarksContainerView.addSubview(remarksHeading)
//        remarksContainerView.addSubview(remarksValue)
//        contentView.addSubview(paymentDetailsStackView)
        contentView.addSubview(shadedView)
        shadedView.addSubview(stackView)
        
        stackView.backgroundColor = UIColor(red: 248, green: 248, blue: 252)
        contentView.backgroundColor = UIColor(red: 248, green: 248, blue: 252)
    }
    
    func setupConstraints() {
     /*
        remarksHeading
            .alignEdgesWithSuperview([.left, .top])

        remarksValue
            .toRightOf(remarksHeading, constant: 40)
            .alignEdgesWithSuperview([.right, .bottom, .top])
        
        paymentDetailsStackViewHeightConstraints = paymentDetailsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15)
         let paymentDetailsStackViewConstraints = [
            paymentDetailsStackViewHeightConstraints!,
            paymentDetailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            contentView.trailingAnchor.constraint(equalTo: paymentDetailsStackView.trailingAnchor, constant: 25)
         ]
        NSLayoutConstraint.activate(paymentDetailsStackViewConstraints)
        
        shadedView
            .toBottomOf(paymentDetailsStackView, constant: isHiddenPaymentDetailsFlag ? 0 : 12)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [0, 0, 0]) */
        
//        stackView
//            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 25, 25, 25])
        
        let stackViewConstraints = [
           stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
           contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 25)
        ]
       NSLayoutConstraint.activate(stackViewConstraints)
        
        stackView
            .alignEdge(.top, withView: contentView,constant: 25)
            .alignEdge(.bottom, withView: contentView,constant: 25)
                   //.alignEdgesWithSuperview([.top, .bottom], constants: [25, 25])
        
      /*  [cardValue, foreignAmountValue, exchangeRateValue, nameValue, amountValue, feeValue, vatValue, totalAmountValue, referenceValue, remarksValue].forEach{ $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        [cardHeading, foreignAmountHeading, exchangeRateHeading, nameHeading, amountHeading, feeHeading, vatHeading, totalAmountHeading, referenceHeading, remarksHeading].forEach{ $0.setContentCompressionResistancePriority(.required, for: .horizontal) } */
        
        [cardValue,  referenceValue].forEach{ $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        [cardHeading,  referenceHeading].forEach{ $0.setContentCompressionResistancePriority(.required, for: .horizontal) }
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [cardHeading.rx.textColor, referenceHeading.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [cardValue.rx.textColor,referenceValue.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func bindViews() {
        
    /*    viewModel.cancelReason.bind(to: cancelReason.rx.text).disposed(by: disposeBag)
        viewModel.cancelReason.map{ $0 == nil }.bind(to: cancelReason.rx.isHidden).disposed(by: disposeBag) */
        
        viewModel.cardValue.bind(to: cardValue.rx.text).disposed(by: disposeBag)
        viewModel.cardValue.map{ $0 == nil }.bind(to: cardStack.rx.isHidden).disposed(by: disposeBag)
        
       /* viewModel.foreignAmountHeading.bind(to: foreignAmountHeading.rx.text).disposed(by: disposeBag)
        viewModel.foreignAmountValue.bind(to: foreignAmountValue.rx.text).disposed(by: disposeBag)
        viewModel.foreignAmountValue.map{ $0 == nil }.bind(to: foreignAmountStack.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.exchangeRateValue.bind(to: exchangeRateValue.rx.text).disposed(by: disposeBag)
        viewModel.exchangeRateValue.map{ $0 == nil }.bind(to: exchangeRateStack.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.userHeading.bind(to: nameHeading.rx.text).disposed(by: disposeBag)
        viewModel.userValue.bind(to: nameValue.rx.text).disposed(by: disposeBag)
        Observable.combineLatest([viewModel.userHeading.map{ $0 == nil }, viewModel.userValue.map{ $0 == nil }])
            .map{ $0.contains(true) }
            .bind(to: nameStack.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.amountHeading.bind(to: amountHeading.rx.text).disposed(by: disposeBag)
        viewModel.amountValue.bind(to: amountValue.rx.text).disposed(by: disposeBag)
        viewModel.amountHeading.map{ $0 == nil }.bind(to: amountStack.rx.isHidden).disposed(by: disposeBag)
        viewModel.feeValue.map {$0 == nil} . bind(to: feeStack.rx.isHidden).disposed(by: disposeBag)
        viewModel.vatValue.map {$0 == nil} .bind(to: vatStack.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.feeValue.bind(to: feeValue.rx.text).disposed(by: disposeBag)
        viewModel.vatValue.bind(to: vatValue.rx.text).disposed(by: disposeBag)
        
        viewModel.totalAmountValue.bind(to: totalAmountValue.rx.text).disposed(by: disposeBag)
        viewModel.totalAmountValue.map{ $0 == nil }.bind(to: totalAmountStack.rx.isHidden).disposed(by: disposeBag) */
        
        viewModel.referenceNumber.bind(to: referenceValue.rx.text).disposed(by: disposeBag)
        viewModel.referenceNumber.map{ $0 == nil }.bind(to: referenceStack.rx.isHidden).disposed(by: disposeBag)
        
      /*  Observable.combineLatest([viewModel.userHeading.map{ $0 == nil }, viewModel.userValue.map{ $0 == nil }])
            .map{ $0.contains(true) }
            .bind(to: nameStack.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.remarks.bind(to: remarksValue.rx.text).disposed(by: disposeBag)
        viewModel.remarks.map{ $0 == nil }.bind(to: remarksStack.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.isHidePaymentDetails.subscribe(onNext: {[weak self] in
            self?.isHiddenPaymentDetailsFlag = $0
            self?.paymentInfo.isHidden = $0
            self?.paymentDetailsStackViewHeightConstraints.constant = $0 ? -15 : 15
        }).disposed(by: disposeBag) */
    }
    
    func setupSensitiveViews() {
       /* UIView.markSensitiveViews([cardValue, foreignAmountValue, exchangeRateValue,
                                   nameValue, amountValue, feeValue,
                                   vatValue, totalAmountValue, referenceValue,
                                   remarksValue]) */
    }
}
