//
//  SMFTBeneficiaryCell.swift
//  YAP
//
//  Created by Zain on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxTheme
import YAPComponents

class SMFTBeneficiaryCell: RxUITableViewCell {
    // MARK: Views
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var flag: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var flagView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var name: UILabel = UIFactory.makeLabel(font: .large, alignment: .center, numberOfLines: 0)
    //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .large, alignment: .center, numberOfLines: 2, lineBreakMode: .byWordWrapping)
    
    private lazy var account: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    // UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [name, account])
    
    // MARK: Properties
    
    private var viewModel: SMFTBeneficiaryCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
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
       
       // MARK: View cycle
       
       override func layoutIfNeeded() {
           super.layoutIfNeeded()
           
           render()
       }
       
       // MARK: Configurations
       
       override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
           guard let viewModel = viewModel as? SMFTBeneficiaryCellViewModelType else { return }
           self.viewModel = viewModel
           self.themeService = themeService
           bindViews()
       }
}

// MARK: View setup

private extension SMFTBeneficiaryCell {
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(flagView)
        flagView.addSubview(flag)
        contentView.addSubview(stackView)
    }
    
    func setupConstraints() {
        userImage
            .alignEdgeWithSuperview(.top, constant: 30)
            .centerHorizontallyInSuperview()
            .height(constant: 64)
            .width(constant: 64)
        
        stackView
            .toBottomOf(userImage, constant: 15)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [25, 25, 15])
        
        flagView
            .alignEdge(.left, withView: userImage, constant: -3)
            .alignEdge(.top, withView: userImage, constant: -2)
            .width(constant: 22)
            .height(constant: 22)
        
        flag
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 2)
    }
    
    func render() {
        userImage.roundView()
        flagView.roundView()
    }
}

// MARK: Binding

private extension SMFTBeneficiaryCell {
    func bindViews() {
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flag.rx.image).disposed(by: disposeBag)
        viewModel.outputs.showsFlag.map { !$0 }.bind(to: flagView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.account.bind(to: account.rx.text).disposed(by: disposeBag)
        viewModel.outputs.account.map { $0 == nil }.bind(to: account.rx.isHidden).disposed(by: disposeBag)
    }
}
