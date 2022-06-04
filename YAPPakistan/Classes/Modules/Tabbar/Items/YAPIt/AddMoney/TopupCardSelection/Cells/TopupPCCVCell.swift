//
//  TopupPCCVCell.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import UIKit
import RxCocoa
import RxSwift
import YAPCore
import YAPComponents
import RxTheme


class TopupPCCVCell: RxUICollectionViewCell {
    
    private lazy var cardImageView: UIImageView = UIFactory.makeImageView() //UIImageViewFactory.createImageView()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_card_info", in: .yapPakistan, compatibleWith: nil)?.asTemplate, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var expiryView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shadowView = UIView()
    
    private lazy var expiryImage: UIImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var expiryViewButton = UIFactory.makeButton(with: .regular)
    
    private lazy var cardTypeImage: UIImageView = UIFactory.makeImageView()
    
    // MARK: Properties
    private var viewModel: TopupPCCVCellViewModelType!
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
        setupViews()
        setupConstraints()
        contentView.clipsToBounds = false
        clipsToBounds = false
        
    }
    
    // MARK: Configuration
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let model = viewModel as? TopupPCCVCellViewModelType else { return }
        self.viewModel = model
        self.themeService = theme
        bindViews()
       // setupTheme()
    }
    
    // MARK: View cycle
    
    override func layoutSubviews() {
        super.layoutIfNeeded()
        render()
        
//        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 15)
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        shadowView.layer.shadowOpacity = 0.2
//        shadowView.layer.shadowRadius = 10
//        shadowView.layer.shadowPath = shadowPath.cgPath
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        render()
    }
    
}

// MARK: View setup
private extension TopupPCCVCell {
    func setupViews() {
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.contentMode = .scaleAspectFit
//        contentView.addSubview(shadowView)
        contentView.addSubview(cardImageView)
        contentView.addSubview(infoButton)
        contentView.addSubview(expiryView)
        contentView.addSubview(cardTypeImage)
        expiryView.addSubview(expiryImage)
        expiryView.addSubview(expiryViewButton)
        
        expiryImage.image = UIImage(named: "icon_invalid", in: .yapPakistan)
        expiryViewButton.backgroundColor = .clear
    }
    
    func setupConstraints() {
        
        cardImageView
            .alignEdgesWithSuperview([.top, .bottom], constant: 5)
            .alignEdgesWithSuperview([.left, .right], constant: 6)
        
//        shadowView
//            .alignEdge(.left, withView: cardImageView, constant: -2)
//            .alignEdge(.top, withView: cardImageView, constant: -1)
//            .alignEdge(.right, withView: cardImageView, constant: -2)
//            .alignEdge(.bottom, withView: cardImageView, constant: -2)
        
        infoButton
            .alignEdgeWithSuperview(.right, constant: 14)
            .alignEdgeWithSuperview(.top, constant: 13)
            .height(constant: 25)
            .width(constant: 25)
        
        expiryViewButton
            .alignAllEdgesWithSuperview()
        
        expiryView
            .alignEdgesWithSuperview([.right, .top], constants: [-10, -10])
            .height(constant: 42)
            .width(constant: 42)
        
        expiryImage
            .height(constant: 20)
            .width(constant: 20)
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
        
        cardTypeImage
            .alignEdgesWithSuperview([.left], constant: 12)
            .centerVerticallyWith(expiryView)
            .height(constant: 12)
            .width(constant: 36)
    }
    
    func render() {
        
        expiryView.addShadowWithCornerRadius(cornerRadius: expiryView.frame.size.height/2)
        expiryView.clipsToBounds = true
    }
}

// MARK: Binding
private extension TopupPCCVCell {
    func bindViews() {
        //TODO: remove following line
        expiryView.isHidden = true
        viewModel.outputs.cardImage.bind(to: cardImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.expired.bind(to: infoButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.expired.map { !$0 }.bind(to: expiryView.rx.isHidden).disposed(by: disposeBag)
        //viewModel.outputs.logoImage.bind(to: cardTypeImage.rx.image).disposed(by: disposeBag)
        
        infoButton.rx.tap.bind(to: viewModel.inputs.infoObserver).disposed(by: disposeBag)
        
        expiryViewButton.rx.tap.bind(to: viewModel.inputs.infoObserver).disposed(by: disposeBag)
        
    }
}
