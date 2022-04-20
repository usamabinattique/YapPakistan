//
//  UserAccountTableViewCell.swift
//  YAP
//
//  Created by Zain on 26/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxCocoa
import RxSwift
import RxTheme
import UIKit

class UserAccountTableViewCell: RxUITableViewCell {
    
    private var viewModel: UserAccountTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    private lazy var userImage: UIImageView = {
        var imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectedRing: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var title: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    
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
    }
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? UserAccountTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
}

// MARK: View setup

private extension UserAccountTableViewCell {
    func setupViews() {
        contentView.addSubview(selectedRing)
        selectedRing.addSubview(userImage)
        contentView.addSubview(title)
    }
    
    func setupConstraints() {
        selectedRing
            .alignEdgeWithSuperview(.top)
            .width(constant: 49)
            .height(constant: 49)
            .centerHorizontallyInSuperview()
        
        
        userImage
            .centerInSuperView()
            .height(constant: 45)
            .width(constant: 45)
        
        title
            .centerHorizontallyInSuperview()
            .toBottomOf(selectedRing, constant: 5)
            .alignEdgeWithSuperview(.bottom, constant: 15, priority: .defaultHigh)
    }
    
    func render() {
        userImage.roundView()
        selectedRing.roundView()
        
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.borderWidth = 1.0
        userImage.layer.masksToBounds = true
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: title.rx.textColor)
            .disposed(by: disposeBag)
    }
}

// MARK: Binding

private extension UserAccountTableViewCell {
    func bindViews() {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
//        viewModel.outputs.isCurrent.subscribe(onNext: { [weak self] in
//            self?.selectedRing.backgroundColor = UIColor.appColor(ofType: ($0.0 ? .primary : .greyLight), forTheme: $0.1 == .household ? .household : .yap)
//        }).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
    }
}
