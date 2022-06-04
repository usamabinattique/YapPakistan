//
//  TDReceiptCollectionViewCell.swift
//  Cards
//
//  Created by Janbaz Ali on 26/10/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxTheme

class TDReceiptCollectionViewCell: RxUICollectionViewCell {
    // MARK: Views
    
    private lazy var roundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var icon: UIImageView = UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.init(named: "icon_add_receipt", in: .yapPakistan))
    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 1)
    private lazy var btnDelete = UIFactory.makeButton(with: .micro)
    
    // MARK: Properties
    
    private var viewModel: TDReceiptCollectionViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
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
        guard let viewModel = viewModel as? TDReceiptCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension TDReceiptCollectionViewCell {
    func setupViews() {
        hStack.addArrangedSubview(icon)
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(btnDelete)
        roundedView.addSubview(hStack)
        contentView.addSubview(roundedView)
        let image = UIImage(named: "icon_close", in: .yapPakistan) ?? UIImage()
       // btnDelete.addRightIcon(image: image)
        btnDelete.setImage(image, for: .normal)
//        btnDelete.imageEdgeInsets =  UIEdgeInsets(top: 0, left: btnDelete.frame.size.width - (image.size.width + 15.0), bottom: 0, right: 0)
//        btnDelete.titleEdgeInsets =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
    
    func setupConstraints() {
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        roundedView
            .height(.equalTo, constant: 32, priority: .defaultLow)
            //.width(.equalTo, constant: 96, priority: .defaultLow)
            .width(.equalTo, constant: 140, priority: .defaultLow)
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constant: 0)
        
        hStack
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [11,10,0,0])
        
        icon
            .width(constant: 16)
            .height(constant: 16)
        
        btnDelete
            .width(constant: 32)
            .height(constant: 32)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [icon.rx.tintColor, titleLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func render() {
        roundedView.layer.cornerRadius = roundedView.bounds.height / 2
        roundedView.layer.borderWidth = 1.1
        roundedView.layer.borderColor = UIColor.lightGray.cgColor
        roundedView.clipsToBounds = true
    }
}

// MARK: Binding

private extension TDReceiptCollectionViewCell {
    func bindViews() {
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        btnDelete.rx.tap.bind(to: viewModel.inputs.deleteReceiptObserver).disposed(by: disposeBag)
    }
}

extension UIButton {
    func addRightIcon(image: UIImage, tintColor: UIColor) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = tintColor
        addSubview(imageView)

        let length = CGFloat(24)
        titleEdgeInsets.right += length

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
}
