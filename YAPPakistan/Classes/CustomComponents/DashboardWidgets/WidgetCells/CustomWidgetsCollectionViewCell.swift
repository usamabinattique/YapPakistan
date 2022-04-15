//
//  CustomWidgetsCollectionViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import UIKit
import RxSwift
import RxDataSources
import YAPComponents
import RxTheme

final class CustomWidgetsCollectionViewCell: RxUICollectionViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cateogryImage: UIImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    var editImage: UIImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit) //UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.init(named: "icon_edit", in: yapKitBundle, compatibleWith: nil))
    var categoryName: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .primary, textStyle: .micro, alignment: .center)
    private var stack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 10)
    private var viewModel: CustomWidgetsCollectionViewCellViewModelType!
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
        guard let viewModel = viewModel as? CustomWidgetsCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        bindViews()
        setupTheme()
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

extension CustomWidgetsCollectionViewCell {
   
    func setupViews()  {
        containerView.addSubview(cateogryImage)
        editImage.image = UIImage.init(named: "icon_edit", in: .yapPakistan)
        addSubview(containerView)
        addSubview(categoryName)
        addSubview(editImage)
    }
    
    func setupConstraints() {
        
        cateogryImage.alignEdgesWithSuperview([.left,.bottom,.top,.right], constant: 15)
        
        containerView
            .height(constant: 64)
            .width(constant: 64)
            .alignEdgesWithSuperview([.left,.top,.right], constant: 8)
        
        editImage
            .height(constant: 74)
            .width(constant: 74)
            .alignEdgeWithSuperview(.top, constant: 4)
            .centerHorizontallyInSuperview()

        categoryName
            .toBottomOf(containerView, constant: 12)
            .alignEdgesWithSuperview([.left,.right,.bottom])
        
    }
    
    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [categoryName.rx.textColor])
            .disposed(by: disposeBag)
    }
    
    func render() {
        containerView.clipsToBounds = true
        containerView.roundView()
        editImage.roundView()
        containerView.applyDarkShadow()
    }
}


//MARK:- Binding

extension CustomWidgetsCollectionViewCell {
   
    func bindViews()  {
        viewModel.outputs.categoryImage.bind(to: cateogryImage.rx.loadImage(true,isStringPath: true)).disposed(by: disposeBag)
        
      /*  viewModel.outputs.categoryImage.subscribe(onNext: { [weak self] _arg0 in
            let (imageUrl,placeholderImg) = _arg0
//            self?.cateogryImage.startAnimating()
            if let url = imageUrl {
                self?.cateogryImage.stopAnimating()
                self?.cateogryImage.sd_setImage(with: URL(string:url))
            } else {
                self?.cateogryImage.image = placeholderImg
            }
            
        }).disposed(by: disposeBag) */
        
        viewModel.outputs.categoryName.bind(to: categoryName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.removeShadow.subscribe(onNext: {[weak self] in
            if $0 == .edit {
                self?.containerView.isHidden = true
                self?.editImage.isHidden = false
            }
            else {
                self?.containerView.isHidden = false
                self?.editImage.isHidden = true
            }
        }).disposed(by: disposeBag) 
    }
}


