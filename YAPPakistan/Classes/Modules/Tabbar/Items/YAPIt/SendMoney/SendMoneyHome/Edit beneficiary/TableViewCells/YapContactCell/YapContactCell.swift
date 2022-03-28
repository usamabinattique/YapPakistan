//
//  YapContactCell.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 17/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

class YapContactCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var name = UIFactory.makeLabel(font: .large)
    private lazy var iban =  UIFactory.makeLabel(font: .small)
    
    private lazy var infoStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 4, arrangedSubviews: [name, iban])
    
    private lazy var addProfilePictureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage.init(named: "icon_add_beneficiary_add_profile", in: .yapPakistan), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    var viewModel: YapContactCellViewModelType!
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
    
    override public func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? YapContactCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
}

// MARK: View setup

private extension YapContactCell {
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(addProfilePictureButton)
        contentView.addSubview(infoStack)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [name.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [iban.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        userImage
            .alignEdgeWithSuperview(.top, constant: 10)
            .alignEdgeWithSuperview(.centerX)
            .height(constant: 70)
            .width(constant: 70)
        
        addProfilePictureButton
            .alignEdges([.right, .bottom], withView: userImage, constants: [-8, -15])
            .height(constant: 36)
            .width(constant: 36)
        
        infoStack
            .toBottomOf(addProfilePictureButton, constant: 8)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, constant: 30)
    }
    
    func render() {
        userImage.roundView()
    }
}

// MARK: Binding

private extension YapContactCell {
    func bindViews() {
        addProfilePictureButton.rx.tap.bind(to: viewModel.inputs.addProfilePictureObserver).disposed(by: disposeBag)
        
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: iban.rx.text).disposed(by: disposeBag)
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
    }
}
