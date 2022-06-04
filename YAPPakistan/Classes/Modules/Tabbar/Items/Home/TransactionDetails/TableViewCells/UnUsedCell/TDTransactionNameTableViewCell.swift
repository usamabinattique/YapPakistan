//
//  TDTransactionNameTableViewCell.swift
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
import RxTheme

public class TDTransactionNameTableViewCell: RxUITableViewCell {
    
    private lazy var parentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var parentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var childOneStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var childTwoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var childThreeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var transactionLogo = UIImageViewFactory.createImageView(mode: .scaleAspectFit)
    
    private lazy var transactionAmount: UILabel = UIFactory.makeLabel(font: .large, alignment: .right) //UILabelFactory.createUILabel(with: .black, textStyle: .large, alignment: .right)
    private lazy var vendorName: UILabel = UIFactory.makeLabel(font: .large, alignment: .left) //UILabelFactory.createUILabel(with: .black, textStyle: .large, alignment: .left)
    
    private lazy var location: UILabel = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .left)
    private lazy var currency: UILabel = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .right)
    
    private lazy var transactionDescription: UILabel = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .secondaryOrange, textStyle: .small, alignment: .left)
    private lazy var descriptionImageView = UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.init(named: "icon_food_drink_orange", in: .yapPakistan)) //TODO: add image
    
    private var viewModel: TDTransactionNameTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
//    override public func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TDTransactionNameTableViewCellViewModelType else { return }
//        self.viewModel = viewModel
//        bind()
//    }
    
    public override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDTransactionNameTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
        setupTheme()
//        setupResources()
    }
    
}

// MARK: SetupViews
private extension TDTransactionNameTableViewCell {
    
    func setupViews() {
        
        vendorName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        transactionAmount.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        location.setContentHuggingPriority(.defaultLow, for: .horizontal)
        currency.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        transactionLogo.layer.cornerRadius = bounds.height/2
        transactionLogo.layer.masksToBounds = false
        transactionLogo.clipsToBounds = true
        
        contentView.backgroundColor = .white
        
        childOneStackView.addArrangedSubview(vendorName)
        childOneStackView.addArrangedSubview(transactionAmount)
        
        childTwoStackView.addArrangedSubview(location)
        childTwoStackView.addArrangedSubview(currency)
        
        childThreeStackView.addArrangedSubview(descriptionImageView)
        childThreeStackView.addArrangedSubview(transactionDescription)
        
        parentStackView.addArrangedSubview(childOneStackView)
        parentStackView.addArrangedSubview(childTwoStackView)
        parentStackView.addArrangedSubview(childThreeStackView)
        
        parentView.addSubview(transactionLogo)
        parentView.addSubview(parentStackView)
        
        contentView.addSubview(parentView)
    }
    
    func setupConstraints() {
        
        parentView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [10, 10, 20, 25])
            .height(constant: 80)
        
        transactionLogo
            .height(constant: 44)
            .width(constant: 44)
            .alignEdges([.left, .top], withView: parentView, constants: [6, 6])
          
        parentStackView
            .alignEdgesWithSuperview([.top, .bottom, .right, .left], constants: [0, 0, 20, 72])
        
        descriptionImageView
        .width(constant: 18)
        
    }
    
    func setupTheme() {
//        themeService.rx
//            .bind({ UIColor($0.primaryDark) }, to: [name.rx.textColor])
//            .disposed(by: rx.disposeBag)
    }
    
    func bind() {
        viewModel.outputs.vendorName.bind(to: vendorName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: transactionAmount.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.location.bind(to: location.rx.text).disposed(by: disposeBag)
        viewModel.outputs.currencySymbol.bind(to: currency.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.descriptionLabel.bind(to: transactionDescription.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.descriptionImage.subscribe(onNext: { image in
            self.descriptionImageView.loadImage(with: URL(string: image.url ?? ""), placeholder: image.initails)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionLogo.subscribe(onNext: { image in
            self.transactionLogo.loadImage(with: URL(string: image.url ?? ""), placeholder: image.initails)
        }).disposed(by: disposeBag)
    }
}
