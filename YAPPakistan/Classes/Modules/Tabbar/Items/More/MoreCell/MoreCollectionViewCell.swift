//
//  MoreCollectionViewCell.swift
//  YAP
//
//  Created by Zain on 19/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MoreCollectionViewCell: RxUICollectionViewCell {
    
    // MARK: Views
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 21
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var title: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping) //.primaryDark
    
    private lazy var background: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var badge: PaddedLabel = {
        let label = PaddedLabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .micro
        label.leftInset = 5
        label.rightInset = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Properties
    
    private var viewModel: MoreCollectionViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? MoreCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        setupBindings()
        setupTheme()
    }
    
}

extension MoreCollectionViewCell: ViewDesignable {
    func setupSubViews() {
        contentView.addSubview(background)
        
        background.addSubview(icon)
        addSubview(title)
        background.addSubview(badgeView)
        badgeView.addSubview(badge)
        
        badge.roundView()
        badgeView.roundView()
    }
    
    func setupConstraints() {
        background
            .alignEdgeWithSuperview(.top, constant: 0)
            .height(constant: 100)
            .aspectRatio()
            .centerHorizontallyInSuperview()
        
        title
            .toBottomOf(background, constant: 10)
            .centerHorizontallyInSuperview()
        
        icon
            .width(constant: 80)
            .height(constant: 80)
        
        icon
            .alignEdgesWithSuperview([.left, .right, .bottom , .top], constant: 10)
        
        badgeView
            .toRightOf(icon, constant: -18)
            .toTopOf(icon, constant: -18)
        
        badge
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 3)
            .height(constant: 20)
            .width(.greaterThanOrEqualTo, constant: 20)
    }
    
    func setupBindings() {
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.badge.map { $0 == nil }.bind(to: badgeView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.badge.bind(to: badge.rx.text).disposed(by: disposeBag)
        viewModel.outputs.disableCell.unwrap().subscribe(onNext:{[weak self] in
            self?.background.isUserInteractionEnabled = !$0
            self?.background.alpha = 0.70
        }).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.secondaryMagenta) }, to: badge.rx.backgroundColor)
            .bind({ UIColor($0.paleLilac) }, to: background.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: title.rx.textColor)
            .disposed(by: disposeBag)
    }
}
