//
//  FAQMenuItemCollectionViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxTheme
import RxCocoa

final class FAQMenuItemCollectionViewCell: RxUICollectionViewCell {
    
    var bgView: UIView = UIFactory.makeView(alpha: 0.1, cornerRadious: 15)
    
    var menuTitle: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    
    private var viewModel: FAQMenuItemCollectionViewCellViewModelType!
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        render()
    }
    
    // MARK: Cofigurations
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? FAQMenuItemCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        setupTheme()
        bindViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
        
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
        
    }
}

//MARK:- View Setup

extension FAQMenuItemCollectionViewCell {
   
    func setupViews()  {
//        containerView.addSubview(cateogryImage)
//        editImage.image = UIImage.init(named: "icon_edit", in: .yapPakistan)
//        addSubview(containerView)
//        addSubview(categoryName)
//        addSubview(editImage)
        addSubview(bgView)
        addSubview(menuTitle)
        //bgView.addSubview(menuTitle)
        //addSubview(menuTitle)
    }
    
    func setupConstraints() {
        
//        cateogryImage.alignEdgesWithSuperview([.left,.bottom,.top,.right], constant: 15)
//
//        containerView
//            .height(constant: 64)
//            .width(constant: 64)
//            .alignEdgesWithSuperview([.left,.top,.right], constant: 8)
//        
//        editImage
//            .height(constant: 74)
//            .width(constant: 74)
//            .alignEdgeWithSuperview(.top, constant: 4)
//            .centerHorizontallyInSuperview()

        bgView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constant: 0)
        menuTitle
            .centerHorizontallyWith(bgView)
            .centerVerticallyWith(bgView)
            .alignEdgesWithSuperview([.left, .right], constant: 10)
        
    }
    
    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [menuTitle.rx.textColor])
            .disposed(by: disposeBag)
        
        //bgView.alpha = 0.1
        menuTitle.textColor = UIColor(themeService.attrs.primaryDark)
    }
    
    func render() {
//        containerView.clipsToBounds = true
//        containerView.roundView()
//        editImage.roundView()
//        containerView.applyDarkShadow()
        
    }
}


//MARK:- Binding

extension FAQMenuItemCollectionViewCell {
   
    func bindViews()  {
        
        viewModel.outputs.menuTitle.bind(to: self.menuTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.isSelected.subscribe(onNext: { [unowned self] isSelectedCell in
            
            
            
            if isSelectedCell! {
                self.bgView.backgroundColor = UIColor(themeService.attrs.primary)
            }
            else {
                self.bgView.backgroundColor = UIColor.clear
            }
            
        }).disposed(by: disposeBag)
        
//        viewModel.outputs.categoryImage.bind(to: cateogryImage.rx.loadImage(true,isStringPath: true)).disposed(by: disposeBag)
//        viewModel.outputs.categoryName.bind(to: categoryName.rx.text).disposed(by: disposeBag)
//        viewModel.outputs.removeShadow.subscribe(onNext: {[weak self] in
//            if $0 == .edit {
//                self?.containerView.isHidden = true
//                self?.editImage.isHidden = false
//            }
//            else {
//                self?.containerView.isHidden = false
//                self?.editImage.isHidden = true
//            }
//        }).disposed(by: disposeBag)
    }
}


