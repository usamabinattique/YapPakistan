//
//  RecentBeneficiaryCollectionViewCell.swift
//  YAPKit
//
//  Created by Zain on 03/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class RecentBeneficiaryCollectionViewCell: RxUICollectionViewCell {
    
    // MARK: - Views
    
    private lazy var flag = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var flagView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var packageIndicator = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 2, lineBreakMode: .byTruncatingTail)  //.greyDark
    
    // MARK: Properties
    
    private var viewModel: RecentBeneficiaryCollectionViewCellViewModelType!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    
    override func draw(_ rect: CGRect) {
        render()
    }
    
    // MARK: Cofigurations
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? RecentBeneficiaryCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews(viewModel)
    }
}

// MARK: - View setup

private extension RecentBeneficiaryCollectionViewCell {
    private func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(flagView)
        contentView.addSubview(packageIndicator)
        contentView.addSubview(nameLabel)
        flagView.addSubview(flag)
    }
    
    private func setupConstraints() {
        userImage
            .alignEdgeWithSuperview(.top, constant: 12)
            .centerHorizontallyInSuperview()
            .width(constant: 40)
            .height(constant: 40)
        
        nameLabel
            .alignEdgesWithSuperview([.left, .right], constant: 8)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 8)
            .toBottomOf(userImage, constant: 2)
        
        flagView
            .alignEdge(.left, withView: userImage, constant: -5)
            .alignEdge(.top, withView: userImage, constant: -4)
            .width(constant: 19)
            .height(constant: 19)
        
        flag
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 2)
        
        packageIndicator
            .alignEdge(.right, withView: userImage, constant: -5)
            .alignEdge(.bottom, withView: userImage, constant: -2)
            .width(constant: 19)
            .height(constant: 19)
    }
    
    func render() {
        userImage.roundView()
        flagView.roundView()
        flag.roundView()
    }
}

// MARK: Binding

private extension RecentBeneficiaryCollectionViewCell {
    func bindViews(_ viewModel: RecentBeneficiaryCollectionViewCellViewModelType) {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        
        let flagImage = viewModel.outputs.country.map { $0 == nil ? nil : UIImage.sharedImage(named: $0!) }
        flagImage.bind(to: flag.rx.image).disposed(by: disposeBag)
        flagImage.map{ $0 == nil }.bind(to: flagView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.package.map{ $0.image }.bind(to: packageIndicator.rx.image).disposed(by: disposeBag)
    }
}
