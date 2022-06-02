//
//  TransactionDetailsTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 02/06/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxTheme

class TransactionDetailTableViewCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var icon = UIImageViewFactory.createImageView(mode: .center, image: nil)
    
    private lazy var title = UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .secondaryMagenta, textStyle: .small)
    
    private lazy var timeDate = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small)
    
    private lazy var amount = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .right)
    
    private lazy var currency = UIFactory.makeLabel(font: .small, alignment: .right) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .right)
    
    private lazy var topStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [title, amount])
    
    private lazy var bottomStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [timeDate, currency])
    
    private lazy var valueStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 3, arrangedSubviews: [topStack, bottomStack])
    
    private lazy var mainStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 25, arrangedSubviews: [iconContainer, valueStack])
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: TransactionDetailsTableViewCellViewModelType!
    private var iconWidthConstaint: NSLayoutConstraint?
    private var iconHeightConstraint: NSLayoutConstraint?
    private var type: AnalyticsDataType = .category
    
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
        render()
    }
    
    // MARK: Configuration
    
//    override func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? TransactionTabelViewCellViewModelType else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionDetailsTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }

}

// MARK: View setup

private extension TransactionDetailTableViewCell {
    func setupViews() {
        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        iconContainer.addSubview(icon)
        amount.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        amount.setContentCompressionResistancePriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        currency.setContentHuggingPriority(.required, for: .horizontal)
        timeDate.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        currency.setContentCompressionResistancePriority(.required, for: .horizontal)
        currency.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupConstraints() {
        iconContainer
            .width(constant: 40)
            .height(constant: 40)
        
        mainStack
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 16, 25, 16])
        
        separator
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [90, 25, 0])
            .height(constant: 1)
        
        icon
            .centerVerticallyInSuperview()
            .centerHorizontallyInSuperview()
            
        self.iconWidthConstaint = icon.widthAnchor.constraint(equalToConstant: 40)
        self.iconHeightConstraint = icon.heightAnchor.constraint(equalToConstant: 40)
        guard let iconWidth = self.iconWidthConstaint, let iconHeight = self.iconHeightConstraint else { return }
        NSLayoutConstraint.activate([iconWidth, iconHeight])
    }
    
    func setupIconConstraint(type: AnalyticsDataType = .merchant) {
        if type == .merchant {
            self.iconWidthConstaint?.constant = 40
            self.iconHeightConstraint?.constant = 40
            icon.layer.cornerRadius = 20
        }
        else {
            self.iconWidthConstaint?.constant = 26
            self.iconHeightConstraint?.constant = 26
            icon.layer.cornerRadius = 0
        }
    }
    
    func render() {
        iconContainer.layer.cornerRadius = 20
        iconContainer.clipsToBounds = true
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .bind({ UIColor($0.grey) }, to: [timeDate.rx.textColor, currency.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [amount.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension TransactionDetailTableViewCell {
    func bindViews() {
        viewModel.outputs.color.subscribe(onNext: { [weak self] in
            self?.title.textColor = $0.0
            self?.icon.tintColor = $0.0
            if $0.1 == .category {
                self?.iconContainer.backgroundColor = $0.0.withAlphaComponent(0.15)
            } else {
                self?.iconContainer.backgroundColor = .clear
            }
        }).disposed(by: disposeBag)

        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.timeDate.bind(to: timeDate.rx.text).disposed(by: disposeBag)
        viewModel.outputs.currency.bind(to: currency.rx.text).disposed(by: disposeBag)
        viewModel.outputs.selected.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.contentView.backgroundColor = $0 ? UIColor.lightGray.withAlphaComponent(0.3) : .clear
            self.title.textColor = $0 ? self.icon.tintColor ?? UIColor( self.themeService.attrs.primaryDark ) : UIColor(self.themeService.attrs.primaryDark)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.type.subscribe(onNext: { [weak self] in self?.icon.contentMode = $0 == .category ? .center : .scaleAspectFill }).disposed(by: disposeBag)
        
        viewModel.outputs.image.subscribe(onNext: {[weak self] args in //(logoUrl,categoryIcon, icon)
            
            if args.0.0 == nil || args.0.0 == "" {
                self?.icon.image = args.0.2
            }
            else {
                self?.icon.loadImage(with: args.0.0 ?? args.0.1, placeholder: args.0.2, showsIndicator: false, completion: { (image, error, url) in
                    self?.icon.image = image?.withRenderingMode(.alwaysOriginal)
                    if args.0.0 == nil {
                    self?.setupIconConstraint(type: args.1)
                    }
                })
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.mode.subscribe(onNext: { [weak self] (mode) in
            self?.icon.contentMode = mode
        }).disposed(by: disposeBag)
    }
}

