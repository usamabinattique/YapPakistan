//
//  AnalyticsCategoryCell.swift
//  YAP
//
//  Created by Zain on 20/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxTheme
import YAPComponents

public class UIImageViewFactory {
    
    public class func createImageView(mode: UIImageView.ContentMode = .scaleAspectFill, image: UIImage? = nil, tintColor: UIColor = .clear) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = mode
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        return imageView
    }
}

public class UIStackViewFactory {
    public class func createStackView(with axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment = .leading, distribution: UIStackView.Distribution = .fillProportionally, spacing: CGFloat = 0, arrangedSubviews: [UIView]? = nil) -> UIStackView {
        let stackView = arrangedSubviews == nil ? UIStackView() : UIStackView(arrangedSubviews: arrangedSubviews!)
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

class AnalyticsCategoryCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var icon = UIImageViewFactory.createImageView(mode: .center, image: nil)
    private lazy var title = UIFactory.makeLabel(font: .small)
    private lazy var transactions = UIFactory.makeLabel(font: .small)
    private lazy var amount = UIFactory.makeLabel(font: .small, alignment: .right)
    private lazy var percentage = UIFactory.makeLabel(font: .small, alignment: .right)
    private lazy var topStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [title, amount])
    
    private lazy var bottomStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [transactions, percentage])
    
    private lazy var valueStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 3, arrangedSubviews: [topStack, bottomStack])
    
    private lazy var mainStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 25, arrangedSubviews: [iconContainer, valueStack])
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    private var viewModel: AnalyticsCategoryCellViewModelType!
    private var iconWidthConstaint: NSLayoutConstraint?
    private var iconHeightConstraint: NSLayoutConstraint?
    private var theme: ThemeService<AppTheme>!
    
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
        setupSensitiveViews()
        render()
    }
    
    // MARK: Configuration
    
    func set(theme: ThemeService<AppTheme>) {
        self.theme = theme
        title.textColor = UIColor(theme.attrs.secondaryMagenta)
        transactions.textColor = UIColor(theme.attrs.greyDark)
        amount.textColor = UIColor(theme.attrs.primaryDark)
        percentage.textColor = UIColor(theme.attrs.greyDark)
        separator.backgroundColor = UIColor(theme.attrs.greyLight)
    }
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        set(theme: themeService)
        guard let vm = viewModel as? AnalyticsCategoryCellViewModelType else {return}
        self.viewModel = vm
        bindViews()
    }
}

// MARK: View setup

private extension AnalyticsCategoryCell {
    func setupViews() {
        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        iconContainer.addSubview(icon)
        amount.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        amount.setContentCompressionResistancePriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        percentage.setContentHuggingPriority(.required, for: .horizontal)
        transactions.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        percentage.setContentCompressionResistancePriority(.required, for: .horizontal)
        percentage.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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
    
    func setupSensitiveViews() {
        // UIView.markSensitiveViews([amount])
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
        icon.clipsToBounds = true
    }
}

// MARK: Binding

private extension AnalyticsCategoryCell {
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
        
        viewModel.outputs.image.subscribe(onNext: {[weak self] args in
            self?.icon.loadImage(with: args.0.0, placeholder: args.0.1, showsIndicator: false, completion: { (image, error, url) in
                if url != nil && args.1 == .category {
                    self?.icon.image = image?.withRenderingMode(.alwaysTemplate)
                } else {
                    self?.icon.image = image?.withRenderingMode(.alwaysOriginal)
                }
            })
        }).disposed(by: disposeBag)
        
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amount.rx.text).disposed(by: disposeBag)
        viewModel.outputs.transactions.bind(to: transactions.rx.text).disposed(by: disposeBag)
        viewModel.outputs.percentage.bind(to: percentage.rx.text).disposed(by: disposeBag)
        viewModel.outputs.selected.subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.contentView.backgroundColor = $0 ? UIColor(self.theme.attrs.greyLight).withAlphaComponent(0.3) : .clear
            self.title.textColor = $0 ? self.icon.tintColor : UIColor(self.theme.attrs.primaryDark)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.type.subscribe(onNext: { [weak self] in
            self?.icon.contentMode = $0 == .category ? .center : .scaleAspectFill
            self?.setupIconConstraint(type: $0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.mode.subscribe(onNext: { [weak self] (mode) in
            self?.icon.contentMode = mode
        }).disposed(by: disposeBag)
        
    }
}

extension UIImage {
      func imageWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
