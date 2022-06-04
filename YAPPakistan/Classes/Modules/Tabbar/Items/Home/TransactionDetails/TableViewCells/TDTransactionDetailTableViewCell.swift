//
//  TDTransactionTableViewCell.swift
//  YAP
//
//  Created by Wajahat Hassan on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import SDWebImage
import RxTheme

public class TDTransactionDetailTableViewCell: RxUITableViewCell {
    
    //MARK: - Properties
    private lazy var transactionLogo = UIFactory.makeImageView() //UIImageViewFactory.createImageView(mode: .center, tintColor: UIColor(themeService.attrs.primary))
    
    private lazy var statusIcon: UIImageView = UIFactory.makeImageView()  //UIImageViewFactory.createImageView(mode: .scaleAspectFit, tintColor: .white)
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var transactionAmount: UILabel = UIFactory.makeLabel(font: .regular, alignment: .right) //UILabelFactory.createUILabel(with: .primary, textStyle: .regular, alignment: .right)
    
    private lazy var transactionName: UILabel = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 2, lineBreakMode: .byTruncatingTail) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .regular, alignment: .left, numberOfLines: 2, lineBreakMode: .byTruncatingTail)
    
    private lazy var transactionType =  UIFactory.makeLabel(font: .micro, alignment: .left) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro, alignment: .left)
    private lazy var transactionTime =  UIFactory.makeLabel(font: .micro, alignment: .left)
    
    private lazy var currencySymbol: UILabel = UIFactory.makeLabel(font: .micro, alignment: .right) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .right)
    
    private lazy var locationLabel = UIFactory.makeLabel(font: .micro, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .left, numberOfLines: 0, lineBreakMode:.byWordWrapping)
    
    private lazy var categoryImageView = UIImageViewFactory.createImageView(mode: .scaleAspectFill, tintColor: .orange)//UIColor(themeService.attrs.secondaryOrange))
    
    private lazy var categoryNameLabel = UIFactory.makeLabel(font: .micro, alignment: .left, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .secondaryOrange, textStyle: .micro, alignment: .left, lineBreakMode: .byWordWrapping)
    
    private lazy var categoryStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 4, arrangedSubviews: [categoryImageView, categoryNameLabel])
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sepratorView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(themeService.attrs.separatorColor).withAlphaComponent(0.11) //UIColor.appColor(ofType: .separatorGrey).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: TDTransactionDetailTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
        
//        setupSensitiveViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TDTransactionDetailTableViewCellViewModelType else { return }
//        self.viewModel = viewModel
//        bind()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDTransactionDetailTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
        setupTheme()
//        setupResources()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }
    
    func render() {
        iconContainer.roundView()
        bindImageGrandientBackground()
    }
    
}

// MARK: SetupViews
private extension TDTransactionDetailTableViewCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        containerView.addSubview(statusIcon)
        containerView.addSubview(transactionName)
        containerView.addSubview(locationLabel)
        containerView.addSubview(categoryStack)
        containerView.addSubview(transactionAmount)
        containerView.addSubview(transactionType)
        containerView.addSubview(transactionTime)
        containerView.addSubview(currencySymbol)
        iconContainer.addSubview(transactionLogo)
        contentView.addSubview(sepratorView)
        transactionLogo.backgroundColor = nil
        
        statusIcon.layer.cornerRadius = 8.5
        statusIcon.clipsToBounds = true
        statusIcon.isHidden = true
        
        transactionLogo.isHidden = true
        transactionType.isHidden = true
    }
    
    func setupConstraints() {
        containerView
            .alignEdgesWithSuperview([.left, .right, .top], constants: [0, 0, 30])
        
        categoryImageView
            .height(constant: 18)
            .width(constant: 18)
        
        iconContainer
            .alignEdgeWithSuperview(.top)
            .alignEdgeWithSuperview(.left, constant: 20)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 0)
            .width(constant: 42)
            .height(constant: 42)
        
        statusIcon
            .alignEdges([.right, .bottom], withView: iconContainer, constants: [-3, -2])
            .width(constant: 17)
            .height(constant: 17)
        
        transactionLogo.alignAllEdgesWithSuperview()
        
        transactionName
            //.toRightOf(iconContainer, constant: 16)
            .alignEdge(.top, withView: iconContainer)
            .alignEdge(.left, withView: iconContainer)
        
//        transactionName
//            .alignEdgeWithSuperview(.top)
//            .alignEdgeWithSuperview(.left, constant: 20)
//            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 0)
        
        transactionType
            .toBottomOf(locationLabel)
            .alignEdge(.left, withView: transactionName)
        
        transactionTime
            .toBottomOf(locationLabel)
            .alignEdge(.left, withView: transactionName)
        
        locationLabel
            .toBottomOf(transactionName, constant: 2)
            .alignEdge(.left, withView: transactionName)
        
        
//        statusIcon
//            .alignEdges([.left,], withView: transactionName, constants: [0])
//            .toBottomOf(transactionName,constant: 12)
//            .width(constant: 17)
//            .height(constant: 17)
        
        
        
//        transactionType
//            .toBottomOf(locationLabel)
//            .alignEdge(.left, withView: transactionName)
        
      /*  categoryStack
            .toBottomOf(transactionType, constant: 6)
            .alignEdge(.left, withView: transactionType)
            .alignEdgeWithSuperview(.bottom, constant: 35) */
        
        categoryStack
            .toBottomOf(transactionTime, constant: 6)
            .alignEdge(.left, withView: transactionType)
            .alignEdgeWithSuperview(.bottom, constant: 35)
        
        transactionAmount
            .toRightOf(transactionName, constant: 5)
            .alignEdge(.top, withView: transactionName)
            .alignEdgeWithSuperview(.right, constant: 20)
        
        currencySymbol
            .toRightOf(locationLabel, constant: 5)
            .toBottomOf(transactionAmount, constant: 2)
            .alignEdgeWithSuperview(.right, constant: 20)
        
        sepratorView
            .toBottomOf(containerView, constant: 10)
            .height(constant: 1)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [80, 20, 0])
        
        transactionAmount.setContentHuggingPriority(.required, for: .horizontal)
        currencySymbol.setContentHuggingPriority(.required, for: .horizontal)
        transactionAmount.setContentCompressionResistancePriority(.required, for: .horizontal)
        currencySymbol.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    }
    
    func bind() {
        viewModel.outputs.amount.bind(to: transactionAmount.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: transactionName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.symbol.bind(to: currencySymbol.rx.text).disposed(by: disposeBag)
        viewModel.outputs.logo.subscribe(onNext: {[weak self] in
            self?.transactionLogo.loadImage(with: $0.0.0, placeholder: $0.0.1)
            self?.transactionLogo.contentMode = $0.1
        }).disposed(by: disposeBag)
        viewModel.outputs.statusIcon.bind(to: statusIcon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.shouldShowSeparator.bind(to: sepratorView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.categoryIcon.bind(to: categoryImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.categoryIcon.map{ $0 == nil }.bind(to: categoryImageView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.categoryName.bind(to: categoryNameLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.categoryName.map{ $0 == nil }.bind(to: categoryImageView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.location.map{ $0 == nil }.bind(to: locationLabel.rx.isHidden).disposed(by: disposeBag)
//        viewModel.outputs.location.bind(to: locationLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.location.subscribe(onNext: { location in
            print("location is \(location)")
        }).disposed(by: disposeBag)

        
        viewModel.outputs.transactionType.bind(to: transactionType.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactionTime.bind(to: transactionTime.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactionTypeTextColor.subscribe(onNext:  {[weak self] in
            self?.transactionType.textColor = $0
            self?.transactionAmount.textColor = $0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancelled.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if $0 {
                self.transactionName.textColor = UIColor(self.themeService.attrs.greyDark) //.greyDark
                self.transactionAmount.textColor =  UIColor(self.themeService.attrs.greyDark)//.greyDark
                self.locationLabel.textColor = UIColor(self.themeService.attrs.primaryDark) //.primaryDark
                self.categoryImageView.alpha = 0.5
                self.categoryNameLabel.alpha = 0.5
            } else {
                self.transactionName.textColor = UIColor(self.themeService.attrs.primaryDark) //.primaryDark
                self.transactionAmount.textColor = UIColor(self.themeService.attrs.primaryDark) //.primaryDark
                self.locationLabel.textColor = UIColor(self.themeService.attrs.greyDark) //.greyDark
                self.categoryImageView.alpha = 1
                self.categoryNameLabel.alpha = 1
            }
        })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isCategoryStackHidden.bind(to: categoryStack.rx.isHidden).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [transactionLogo.rx.tintColor, transactionAmount.rx.textColor])
            .bind({ UIColor($0.backgroundColor) }, to: [statusIcon.rx.tintColor])
            .bind({ UIColor($0.primaryDark) }, to: [transactionName.rx.textColor,transactionType.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [currencySymbol.rx.textColor,transactionTime.rx.textColor])
            .bind({ UIColor($0.greyLight) }, to: [sepratorView.rx.backgroundColor])
            .bind({ UIColor($0.secondaryOrange) }, to: [categoryImageView.rx.tintColor, categoryNameLabel.rx.textColor])
        
            .disposed(by: rx.disposeBag)
    }
    
    func setupSensitiveViews() {
//        UIView.markSensitiveViews([self.contentView])
    }
    
    func bindImageGrandientBackground() {
        viewModel.outputs.addVirtualCardDesignGradient.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] colors in
            if colors?.count == 1 {
                self?.iconContainer.backgroundColor = colors?.first
            } else if let colors = colors, colors.count > 1 {
                self?.iconContainer.setGradientBackground(colors: colors)
            }
        }).disposed(by: disposeBag)
    }
}
