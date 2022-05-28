//
//  TDTransactionTotalPurchaseTableViewCell.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import SDWebImage
import RxTheme
import UIKit

public class TDTransactionTotalPurchaseTableViewCell: RxUITableViewCell {
    
    private lazy var parentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
     
    private lazy var forwardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "icon_forward", in: .yapPakistan) //UIImage.sharedImage(named: "icon_forward")
        if #available(iOS 13.0, *) {
            imageView.image = UIImage.init(named: "icon_forward", in: .yapPakistan)?.withTintColor(UIColor(themeService.attrs.primary))  //UIImage.sharedImage(named: "icon_forward")?.withTintColor(.primary)
        } else {
            imageView.image = UIImage.init(named: "icon_forward", in: .yapPakistan)?.asTemplate
            imageView.tintColor = UIColor(themeService.attrs.primary)
        }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var bottomSepratorContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var averageAmountContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var totalAmountContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var purchaseStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var purchaseInnerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var sepratorView1: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor(themeService.attrs.separatorColor).withAlphaComponent(0.11) //UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sepratorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(themeService.attrs.separatorColor).withAlphaComponent(0.11) //UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sepratorView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(themeService.attrs.separatorColor).withAlphaComponent(0.11) //UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var averageAmountStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var totalAmountStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
//    icon_forward
    
    //    private lazy var actionLogo = UIImageViewFactory.createImageView(mode: .scaleAspectFit, tintColor: UIColor.primary)
    private lazy var purchaseTitle: UILabel = UIFactory.makeLabel(font: .small, alignment: .left, text: "Total Transactions") //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .left, text: "Total Transactions")
    private lazy var purchaseCount: UILabel = UIFactory.makeLabel(font: .large, alignment: .right) //UILabelFactory.createUILabel(with: .primary, textStyle: .large, alignment: .right)
    private lazy var averageTitle: UILabel = UIFactory.makeLabel(font: .small, alignment: .center,  text: "Average") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, text: "Average")
    private lazy var averageAmount: UILabel = UIFactory.makeLabel(font: .title3, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title3, alignment: .center)
    private lazy var averageAmountCurrencySymbol: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "PKR") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, text: "AED")
    private lazy var totalAmountTitle: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "Total") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, text: "Total")
    private lazy var totalAmount: UILabel = UIFactory.makeLabel(font: .title3, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title3, alignment: .center)
    private lazy var totalAmountCurrencySymbol: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "PKR") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, text: "AED")
    
    private var viewModel: TDTransactionTotalPurchaseTableViewModel!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
        setupSensitiveViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TDTransactionTotalPurchaseTableViewModel else { return }
//        self.viewModel = viewModel
//        bind()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDTransactionTotalPurchaseTableViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
        setupTheme()
       // setupResources()
    }
    
}

// MARK: SetupViews
private extension TDTransactionTotalPurchaseTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        
        purchaseTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
        purchaseCount.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        purchaseInnerStackView.addArrangedSubview(purchaseTitle)
        purchaseInnerStackView.addArrangedSubview(purchaseCount)
        purchaseInnerStackView.addArrangedSubview(forwardImageView)
        
        purchaseStackView.addArrangedSubview(sepratorView1)
        purchaseStackView.addArrangedSubview(purchaseInnerStackView)
        purchaseStackView.addArrangedSubview(sepratorView2)
        
        averageAmountStackView.addArrangedSubview(averageTitle)
        averageAmountStackView.addArrangedSubview(averageAmount)
        averageAmountStackView.addArrangedSubview(averageAmountCurrencySymbol)
        
        totalAmountStackView.addArrangedSubview(totalAmountTitle)
        totalAmountStackView.addArrangedSubview(totalAmount)
        totalAmountStackView.addArrangedSubview(totalAmountCurrencySymbol)
        
        bottomSepratorContainer.addSubview(sepratorView3)
        
        averageAmountContainerView.addSubview(averageAmountStackView)
        totalAmountContainerView.addSubview(totalAmountStackView)
        
        stackView.addArrangedSubview(averageAmountContainerView)
        stackView.addArrangedSubview(bottomSepratorContainer)
        stackView.addArrangedSubview(totalAmountContainerView)
        
        parentView.addSubview(purchaseStackView)
        parentView.addSubview(stackView)
        
        contentView.addSubview(parentView)
    }
    
    func setupConstraints() {
        
        parentView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [10, 10, 20, 0])
        
        sepratorView1
            .height(constant: 1.3)
        
        sepratorView2
            .height(constant: 1.3)
        
        sepratorView3
            .width(constant: 1.3)
            .height(constant: 80)
            .centerInSuperView()
        
        purchaseStackView
            .alignEdgesWithSuperview([.left, .right, .top], constants: [10, 10, 0])
            .height(constant: 50)
        
        averageAmountContainerView
            .height(constant: 120)
        
        bottomSepratorContainer
            .width(constant: 20)
        
        totalAmountContainerView
            .height(with: .height, ofView: averageAmountContainerView)
            .width(with: .width, ofView: averageAmountContainerView)
        
        averageAmountStackView
            .centerInSuperView()
        
        totalAmountStackView
            .centerInSuperView()
        
        stackView
            .toBottomOf(purchaseStackView, constant: 7)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [0, 0, 0])
        
    }
    
    func setupTheme() {
//        themeService.rx
//            .bind({ UIColor($0.primaryDark) }, to: [name.rx.textColor])
//            .disposed(by: rx.disposeBag)
    }
    
    func setupSensitiveViews() {
//        UIView.markSensitiveViews([purchaseCount, averageAmount, totalAmount])
    }
    
    func bind() {
        viewModel.purchaseCount.map{ "\($0 ?? -1)" }.unwrap().bind(to: purchaseCount.rx.text).disposed(by: disposeBag)
        viewModel.averageAmount.map{ CurrencyFormatter.formatAmountInLocalCurrency($0 ?? 0.0).amountFromFormattedAmount }.bind(to: averageAmount.rx.text).disposed(by: disposeBag)
        viewModel.totalAmount.map{ CurrencyFormatter.formatAmountInLocalCurrency($0 ?? 0.0 ).amountFromFormattedAmount }.bind(to: totalAmount.rx.text).disposed(by: disposeBag)
    }
}
